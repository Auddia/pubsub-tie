require 'spec_helper'

module PubSubTie
  RSpec.describe Publisher do
    let(:pubconf) { {'project_id' => 'proj', 'keyfile' => 'kf.json'} }
    let(:config) { {'app_prefix' => 'test',
                    'events' =>[{
                      'name' =>'event_zero',
                      'required' => [{'name' => 'req1', 'type' => 'INT'},
                                     {'name' => 'event_name', 'type' => 'STRING'}, 
                                     {'name' => 'event_time', 'type' => 'TIMESTAMP'}],
                      'optional' => [{'name' => 'opt1', 'type' => 'INT'}], 
                      'repeated' => [{'name' => 'rep1', 'type' => 'INT'}] 
                    }] } }

    before(:each) do
      Events.configure(config)
      Publisher.configure(pubconf)
      # Freeze time
      travel_to Time.current
    end

    describe ".publish" do
      subject { Publisher.publish(:event_zero, data, nil) }
      let(:data) { {req1: 1} }

      it 'produces a topic named after the event name' do
        expect(PubSubTie::Google::PubSub::Mock).
            to receive(:topic).
            with(Events.full_name(:event_zero)).
            and_call_original
        subject
      end

      describe 'message' do
        let(:augmented) { {req1: 1,
                           event_name: Events.name(:event_zero),
                           event_time: Time.current.utc} }
        let(:req1) { 1 }


        context "with missing required attributes" do
          let(:data) { {} }

          it "raises ArgumentError" do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context "with required attributes" do
          context 'with only listed attributes' do
            let(:data) { {req1: req1} }

            it "augments them to include name and time" do
              expect(PubSubTie::Google::PubSub::Topic).
                to receive(:publish_async).
                with(augmented.to_json, anything)
              subject
            end

            context 'with a bad type' do
              let(:req1) { '1.1' }

              it "raises an ArgumentError" do
                expect { subject }.to raise_error(ArgumentError)
              end
            end
          end

          context 'with non-listed attributes' do
            let(:data) { {req1: req1, bogus: 'bravo'} }

            it "ignores them" do
              expect(PubSubTie::Google::PubSub::Topic).
                to receive(:publish_async).
                with(augmented.to_json, anything)
              subject
            end
          end

          context 'with optional attributes' do
            let(:data) { {req1: req1, opt1: opt1} }

            context 'with a bad type' do
              let(:opt1) { 'not int' }

              it "raises an ArgumentError" do
                expect { subject }.to raise_error(ArgumentError)
              end
            end

            context 'with a good type' do
              let(:opt1) { 1 }

              it "works" do
                expect { subject }.not_to raise_error
              end
            end
          end

          context 'with repeated (array) attributes' do
            let(:data) { {req1: req1, rep1: rep1} }

            context 'with a bad type' do
              let(:rep1) { [1, 'bad'] }

              it "raises an ArgumentError" do
                expect { subject }.to raise_error(ArgumentError)
              end
            end

            context 'with a good type' do
              let(:rep1) { [1, 2] }

              it "works" do
                expect { subject }.not_to raise_error
              end
            end
          end
        end
      end
    end

    describe ".google_pubsub" do
      before do
        allow(PubSubTie::Publisher).to receive(:google_pubsub).and_call_original
        allow(ENV).to receive(:[]).and_call_original
      end

      context "when keyfile is specified and non-empty" do
        let(:fake_creds) { double('Credentials') }

        it "initializes PubSub with explicit credentials from relative keyfile path" do
          config = { 'project_id' => 'my-proj', 'keyfile' => 'service-account.json' }
          expected_path = File.join(PubSubTie.app_root, 'config', 'service-account.json')
          expect(::Google::Cloud::PubSub::Credentials).to receive(:new).with(expected_path).and_return(fake_creds)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'my-proj', credentials: fake_creds)

          Publisher.google_pubsub(config)
        end

        it "initializes PubSub with explicit credentials from absolute keyfile path" do
          config = { 'project_id' => 'my-proj', 'keyfile' => '/secrets/gcp/key.json' }
          expect(::Google::Cloud::PubSub::Credentials).to receive(:new).with('/secrets/gcp/key.json').and_return(fake_creds)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'my-proj', credentials: fake_creds)

          Publisher.google_pubsub(config)
        end
      end

      context "when keyfile is nil or empty (keyless ADC mode)" do
        let(:fake_pubsub) { double('PubSub') }

        it "initializes PubSub without credentials when keyfile is nil" do
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'my-proj').and_return(fake_pubsub)

          Publisher.google_pubsub({ 'project_id' => 'my-proj', 'keyfile' => nil })
        end

        it "initializes PubSub without credentials when keyfile is empty string" do
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'my-proj').and_return(fake_pubsub)

          Publisher.google_pubsub({ 'project_id' => 'my-proj', 'keyfile' => '   ' })
        end

        it "initializes PubSub without credentials when keyfile key is omitted" do
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'my-proj').and_return(fake_pubsub)

          Publisher.google_pubsub({ 'project_id' => 'my-proj' })
        end

        it "uses ENV['GOOGLE_CLOUD_PROJECT'] if set and config has no project_id" do
          allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_PROJECT').and_return('env-project-123')
          allow(ENV).to receive(:[]).with('PUBSUB_PROJECT').and_return(nil)
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'env-project-123').and_return(fake_pubsub)

          Publisher.google_pubsub({})
        end

        it "uses ENV['PUBSUB_PROJECT'] if set and GOOGLE_CLOUD_PROJECT is not set" do
          allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_PROJECT').and_return(nil)
          allow(ENV).to receive(:[]).with('PUBSUB_PROJECT').and_return('pubsub-env-project')
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(project_id: 'pubsub-env-project').and_return(fake_pubsub)

          Publisher.google_pubsub({})
        end

        it "does not pass project_id or default to prod when project_id and ENV are not provided" do
          allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_PROJECT').and_return(nil)
          allow(ENV).to receive(:[]).with('PUBSUB_PROJECT').and_return(nil)
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(no_args).and_return(fake_pubsub)

          Publisher.google_pubsub({})
        end

        it "handles nil config gracefully without defaulting to prod" do
          allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_PROJECT').and_return(nil)
          allow(ENV).to receive(:[]).with('PUBSUB_PROJECT').and_return(nil)
          expect(::Google::Cloud::PubSub::Credentials).not_to receive(:new)
          expect(::Google::Cloud::PubSub).to receive(:new).with(no_args).and_return(fake_pubsub)

          Publisher.google_pubsub(nil)
        end
      end
    end

    describe "with root-level common fields and auto event_id generation" do
      let(:common_config) { {
        'app_prefix' => 'test',
        'common' => [
          {'name' => 'event_id', 'type' => 'STRING', 'mode' => 'REQUIRED'},
          {'name' => 'event_name', 'type' => 'STRING', 'mode' => 'REQUIRED'},
          {'name' => 'event_time', 'type' => 'TIMESTAMP', 'mode' => 'REQUIRED'}
        ],
        'events' => [{
          'name' => 'event_one',
          'required' => [{'name' => 'req1', 'type' => 'INT'}]
        }]
      } }

      before(:each) do
        Events.configure(common_config)
      end

      it "automatically inherits common fields and auto-generates event_id" do
        expect(Events.required(:event_one)).to include(:event_id, :event_name, :event_time)

        expect(PubSubTie::Google::PubSub::Topic).to receive(:publish_async) do |payload_json, _|
          payload = JSON.parse(payload_json)
          expect(payload['req1']).to eq(1)
          expect(payload['event_name']).to eq('event_one')
          expect(payload['event_id']).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/)
        end

        Publisher.publish(:event_one, {req1: 1}, nil)
      end

      it "preserves caller-supplied event_id" do
        expect(PubSubTie::Google::PubSub::Topic).to receive(:publish_async) do |payload_json, _|
          payload = JSON.parse(payload_json)
          expect(payload['event_id']).to eq('custom-caller-id-123')
        end

        Publisher.publish(:event_one, {req1: 1, event_id: 'custom-caller-id-123'}, nil)
      end

      it "handles explicit nil event_id by generating a fallback UUID" do
        expect(PubSubTie::Google::PubSub::Topic).to receive(:publish_async) do |payload_json, _|
          payload = JSON.parse(payload_json)
          expect(payload['event_id']).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/)
        end

        Publisher.publish(:event_one, {req1: 1, event_id: nil}, nil)
      end
    end
  end
end
