require "ostruct"

class Yamlconfig
  attr_accessor :config, :env_file

  # Accepts:
  #   config - Yamlconfig::Config
  def initialize(config)
    @config = config
    reload
  end

  def reload
    @env_file = deep_merge(
      YAML.load_file(config.default_file), YAML.load_file(config.env_file)
    )

    @env_file.each do |key, value|
      self.class.send(:define_method, key, proc {
        value.is_a?(Hash) ? RecursiveOpenStruct.new(value) : value
      })
    end
  end

  private

  class RecursiveOpenStruct
    def initialize(hash)
      hash.each do |key, value|
        self.class.send(:define_method, key, proc {
          value.is_a?(Hash) ? RecursiveOpenStruct.new(value) : value
        })
      end
    end
  end

  class Config
    attr_accessor :default_file, :env, :env_files

    def initialize(&blk)
      blk.call(self) if blk

      assert_valid_default_file
    end

    def env
      @env || :development
    end

    def env=(env)
      @env = env.to_sym
    end

    def env_files=(files)
      raise ErrEnvFilesNotHash if !files.is_a?(Hash)

      files.each { |key, val| files[key.to_sym] = val }

      raise ErrFileNotFound if !File.exist?(files[env])

      @env_files = files
    end

    def env_file
      env_files[env]
    end

    private

    def assert_valid_default_file
      raise ErrFileNotFound, default_file if !File.exist?(default_file)
    end

    class ErrEnvFilesNotHash < StandardError; end
    class ErrFileNotFound < StandardError; end
  end

  def deep_merge(first, second)
    merger = proc do |key, v1, v2|
      if Hash === v1 && Hash === v2
        v1.merge(v2, &merger)
      else
        if Array === v1 && Array === v2
          v1 | v2
        else
          [:undefined, nil, :nil].include?(v2) ? v1 : v2
        end
      end
    end

    first.merge(second.to_h, &merger)
  end
end
