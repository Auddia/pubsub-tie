require 'spec_helper'

module PubSubTie
  RSpec.describe Publisher do
    let(:pubconf) { {'project' => 'proj', 'keyfile' => 'kf.json'} }
    let(:config) { {'app_prefix' => 'test',
                    'events' =>[{
                      'name' =>'event_zero',
                      'required' =>['req1'],
                      'optional' =>['opt1']}] } }

    before(:each) do
      Events.configure(config)
      Publisher.configure(pubconf)
    end

    describe ".publish" do
      subject { Publisher.publish(:event_zero, data, nil) }
      let(:data) { {req1: 'alpha'} }

      it 'produces a topic named after the event name' do
        expect(PubSubTie::Google::PubSub::Mock).
            to receive(:topic).
            with(Events.name(:event_zero)).
            and_call_original
        subject
      end

      describe 'message' do
        context "with missing required attributes" do
          let(:data) { {} }

          it "raises ArgumentError" do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context "with required attributes" do
          context 'with non-listed attributes' do
            let(:data) { {req1: 'alpha', bogus: 'bravo'} }

            it "ignores them" do
              expect(PubSubTie::Google::PubSub::Topic).
                to receive(:publish_async).
                with({req1: 'alpha'}.to_json, anything)
              subject
            end
          end
        end
      end
    end
  end
end
