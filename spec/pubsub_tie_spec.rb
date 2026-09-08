require 'tempfile'

RSpec.describe PubSubTie do
  it "has a version number" do
    expect(PubSubTie::VERSION).to eq("1.6.1")
  end

  describe ".load_yaml_file" do
    let(:tmp_file) { Tempfile.new(['config', '.yml']) }

    after do
      tmp_file.close
      tmp_file.unlink
    end

    it "loads YAML content successfully" do
      tmp_file.write("production:\n  project_id: test-project\n")
      tmp_file.rewind

      result = described_class.load_yaml_file(tmp_file.path)
      expect(result).to eq({ "production" => { "project_id" => "test-project" } })
    end

    context "when running under Psych < 4.0.0 (Psych 3 / Ruby 2.7)" do
      it "calls YAML.load_file without aliases keyword argument" do
        stub_const("Psych::VERSION", "3.1.0")
        expect(YAML).to receive(:load_file).with(tmp_file.path).and_return({ "test" => "ok" })

        result = described_class.load_yaml_file(tmp_file.path)
        expect(result).to eq({ "test" => "ok" })
      end
    end

    context "when running under Psych >= 4.0.0 (Ruby 3.x)" do
      it "calls YAML.load_file with aliases: true" do
        stub_const("Psych::VERSION", "5.1.0")
        expect(YAML).to receive(:load_file).with(tmp_file.path, aliases: true).and_return({ "test" => "ok" })

        result = described_class.load_yaml_file(tmp_file.path)
        expect(result).to eq({ "test" => "ok" })
      end
    end
  end
end
