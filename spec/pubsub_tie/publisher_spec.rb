require 'spec_helper'

module PubSubTie
  RSpec.describe Publisher do
    let(:pubconf) { {'project' => 'proj', 'keyfile' => 'kf.json'} }
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
  end
end
