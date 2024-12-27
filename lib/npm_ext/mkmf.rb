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
      parse_package_json(dir).map do |package|
        configs = "rollup.config.#{Digest::MD5.hexdigest(package.name.to_s)}.js"
        File.write(configs, "module.exports = #{JSON.generate(
          {
            # TODO: if no file provided get the input file from package.json
            input: "node_modules/#{package.name}/#{package.file_to_bundle}",
            output: {
              file: "#{package.name}.npm_ext.js",
              name: package.name,
              format: "iife",
            },
            plugins: ROLLUP_PLUGINS.map do |x|
              RollupConfigPlugin.new x
            end,
          },
        )}")
        configs
      end
    end

    def create_npm_makefile(dir)
      configs = create_rollup_config(dir)
      File.write("Makefile", <<~MAKE)
        install:
        \tcp #{dir}/package*.json ./ || :
        \tnpm ci
        \tnpm i #{ROLLUP_PACKAGES.join(" ")}
        #{configs.map { |x| "\tnpx rollup --config #{x}" }.join("\n")}
        \tcat *.npm_ext.js > npm_ext.so
        \tcp *.npm_ext.js ../../../../lib/
      MAKE
    end
  end
end

include NpmExt::Mkmf # rubocop:disable Style/MixinUsage
