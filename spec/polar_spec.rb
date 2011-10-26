require_relative 'spec_helper'

describe Robut::Plugin::Quiz::Polar do
  
  subject do
    Robut::Plugin::Quiz::Polar.new 'person',"'Should I continue the presentation?'"
  end
  
  let(:time) { Time.now }
  
  describe "#handle_response" do
    
    context "when the response is a 'yes'" do
      
      it "should store positive response for the user" do
        
        subject.should_receive(:store_positive_response_for).with('person')
        subject.handle_response('person','yes')
        
      end
      
    end

    context "when the response is a 'y'" do
      
      it "should store a positive response for the user" do
        
        subject.should_receive(:store_positive_response_for).with('person')
        subject.handle_response('person','y')

      end
    end
    
    context "when the response is a 'no'" do
      
      it "should store negative response for the user" do
        
        subject.should_receive(:store_negative_response_for).with('person')
        subject.handle_response('person','no')
        
      end
      
    end
    
    context "when the response is a 'n'" do
      
      it "should store negative response for the user" do
      
        subject.should_receive(:store_negative_response_for).with('person')
        subject.handle_response('person','n')
        
      end
      
    end
    
  end
  
  describe "#declare_results" do
    
    context "when there have been no votes" do
      
      it "should reply that there are zero YES votes and zero NO votes" do
        
        subject.results.should eq "0 YES votes and 0 NO votes"
        
      end
      
    end
    
    context "when there has been a yes vote" do
      
      it "should reply that there is 1 YES vote" do
        
        subject.handle_response('person','yes')
        subject.results.should eq "1 YES vote and 0 NO votes"
        
      end
      
    end
    
    context "when there has been a no vote" do
      
      it "should reply that there is 1 NO vote" do
        
        subject.handle_response('person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end
      
    end
    
    context "when there has been multiple votes by the same user" do
      
      it "should count as one vote" do
        
        subject.handle_response('person','no')
        subject.handle_response('person','no')
        subject.handle_response('person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end

      it "should only count the last vote" do
        
        subject.handle_response('person','yes')
        subject.handle_response('person','yes``')
        subject.handle_response('person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end
      
    end
    
  end
  
  
end