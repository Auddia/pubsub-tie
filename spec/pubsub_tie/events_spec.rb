require 'spec_helper'

module PubSubTie
  RSpec.describe Events do
    before(:each) { Events.configure(config) }
    
    let(:config) { {'app_prefix' => 'test',
                    'events' =>[{
                      'name' =>'event_zero',
                      'required' =>['req1', 'req2'],
                      'optional' =>['opt1']}] } }

    describe ".name" do
      context "when the event for the symbol is defined" do
        it "preprends the application prefix" do
          expect(Events.name(:event_zero)).to eq('test-event_zero')
        end
      end

      context "when the event for the symbol is not defined" do
        it "raises a KeyError" do
          expect {Events.name(:bad_name)}.to raise_error(KeyError)
        end
      end
    end
  end
end
