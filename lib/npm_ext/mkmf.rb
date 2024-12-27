require "digest"
require "json"
require "mkmf"

module NpmExt
  module Mkmf
    class RollupConfigPlugin
      def initialize(name)
        @name = name
      end

      def to_json(*_args)
        <<~JS
          require("#{@name}")()
        JS
      end
    end

    PackageEntry = Struct.new(
      :name,
      :file_to_bundle,
      keyword_init: true,
    )

    ROLLUP_PLUGINS = %i[
      @rollup/plugin-commonjs
      @rollup/plugin-node-resolve
      @rollup/plugin-json
      @rollup/plugin-terser
    ].freeze

    ROLLUP_PACKAGES = (ROLLUP_PLUGINS + %i[rollup]).freeze

    def parse_package_json(dir)
      packages = JSON.parse(File.read("#{dir}/package.json"), symbolize_names: true)
      packages[:dependencies].map do |x, _|
        PackageEntry.new(
          name: x,
          file_to_bundle: packages[:fileToBundle][x],
        )
      end
    end

    def create_rollup_config(dir)
      parse_package_json(dir).to_h do |package|
        hash = Digest::MD5.hexdigest(package.name.to_s)
        config = "rollup.config.#{hash}.js"
        output_js = "#{hash}.npm_ext.js"
        File.write(config, "module.exports = #{JSON.generate(
          {
            # TODO: if no file provided get the input file from package.json
            input: "node_modules/#{package.name}/#{package.file_to_bundle}",
            output: {
              file: output_js,
              name: package.name,
              format: "iife",
            },
            plugins: ROLLUP_PLUGINS.map do |x|
              RollupConfigPlugin.new x
            end,
          },
        )}")
        [package.name, {
          rollup_config: config,
          output_js: output_js,
        }]
      end
    end

    def create_npm_makefile(dir)
      configs = create_rollup_config(dir)
      File.write("Makefile", <<~MAKE)
        install:
        \tcp #{dir}/package*.json ./ || :
        \tnpm ci
        \tnpm i #{ROLLUP_PACKAGES.join(" ")}
        #{configs.map { |_, x| "\tnpx rollup --config #{x[:rollup_config]}" }.join("\n")}
        \trm -rf npm_ext.so
        \tnode -e 'const fs = require("fs"); fs.writeFileSync("npm_ext.so", JSON.stringify(Object.fromEntries(#{configs.transform_values { |x| x[:output_js] }.to_a.to_json}.map(([k, v]) => [k, fs.readFileSync(v, "utf8")]))))'
        clean:
        \trm -rf node_modules
        \trm -rf rollup.config.*.js
        \trm -rf *npm_ext.js
      MAKE
    end
  end
end

include NpmExt::Mkmf # rubocop:disable Style/MixinUsage
