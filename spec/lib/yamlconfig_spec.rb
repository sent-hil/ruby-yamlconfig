require "spec_helper"

describe Yamlconfig do
  let(:valid_config) do
    Yamlconfig::Config.new do |c|
      c.default_file = "spec/fixtures/app.yml"
      c.env_files    = {
        development: "spec/fixtures/app_development.yml",
        staging:     "spec/fixtures/app_staging.yml"
      }
    end
  end

  let(:y) { Yamlconfig.new(valid_config) }

  context "config" do
    it "gets/sets attributes" do
      expect(valid_config.default_file).to eq("spec/fixtures/app.yml")
      expect(valid_config.env_files[:development]).to eq("spec/fixtures/app_development.yml")
    end

    it "raises error when trying to set env_files to not hash" do
      expect do
        Yamlconfig::Config.new do |c|
          c.default_file = "spec/fixtures/app.yml"
          c.env_files = "spec/fixtures/app.yml"
        end
      end.to raise_error(Yamlconfig::Config::ErrEnvFilesNotHash)
    end

    it "raises error if config file is not found" do
      expect do
        Yamlconfig::Config.new do |c|
          c.default_file = "nonexistent"
        end
      end.to raise_error(Yamlconfig::Config::ErrFileNotFound)
    end

    it "raises error if any of files passed to env_files is not found" do
      expect do
        Yamlconfig::Config.new do |c|
          c.default_file = "spec/fixtures/app.yml"
          c.env_files = { development: "nonexistent" }
        end
      end.to raise_error(Yamlconfig::Config::ErrFileNotFound)
    end
  end

  it "returns development as default env if not set" do
    expect(valid_config.env).to eq(:development)
  end

  context "env" do
    before { valid_config.env = :staging }

    it "returns set env after it's set" do
      expect(valid_config.env).to eq(:staging)
    end

    it "converts env to symbol when setting" do
      valid_config.env = "staging"
      expect(valid_config.env).to eq(:staging)
    end

    it "gets attribute from env file" do
      expect(y.namespace2.key1).to eq("only in staging")
    end
  end

  it "loads yaml from set config" do
    expect(y.env_file).to_not be_nil
  end

  it "gets attribute from appropriate env file" do
    expect(y.namespace2.key1).to eq("only in development")
  end

  it "gets attribute overriden from default file" do
    expect(y.namespace1.key2).to eq("overriden from default")
  end

  it "gets attributes from default when not in env file" do
    expect(y.namespace1.key1).to eq("default")
  end

  it "gets several layers nested key" do
    expect(y.namespace3.key1.key2.key3.key4).to eq("deeply nested")
  end

  it "reloads config on reload" do
    expect(y.namespace2.key1).to eq("only in development")

    y.config.env = :staging
    y.reload

    expect(y.namespace2.key1).to eq("only in staging")
  end
end
