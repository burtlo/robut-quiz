require_relative 'spec_helper'

describe Robut::Plugin::Quiz::Choice do
  
  subject do
    Robut::Plugin::Quiz::Choice.new 'person',"'Should I continue the presentation?' 'yes', 'no', 'meh'"
  end
  
  let(:time) { Time.now }
  
  describe "#handle_response" do
    
    context "when the response is a 'yes'" do
      
      it "should store the yes response for the user" do
        
        subject.should_receive(:store_response).with('person','yes')
        subject.handle_response('person','yes')
        
      end
      
    end
    
    context "when the response is a 'no'" do
      
      it "should store the no response for the user" do
        
        subject.should_receive(:store_response).with('person','no')
        subject.handle_response('person','no')
        
      end
    end
    
    context "when the response is a 'meh'" do
      
      it "should store the meh response for the user" do
        
        subject.should_receive(:store_response).with('person','meh')
        subject.handle_response('person','meh')
        
      end
    end
    
    context "when the response is not valid" do
      
      it "should not store the response for the user" do
        
        subject.handle_response('person','no way').should be_false
        
      end
      
    end

  end
  

  describe "#declare_results" do
    
    context "when there have been no votes" do
      
      it "should reply that there are no votes" do
        
        subject.results.should eq "No votes have been made"
        
      end
      
    end
    
    context "when there has been a 'yes' vote" do
      
      it "should reply that there is 1 'yes' vote" do
        
        subject.handle_response('person','yes')
        subject.results.should eq "1 'yes'"
        
      end
      
    end
    
    context "when there has been a 'no' vote" do
      
      it "should reply that there is 1 'no' vote" do
        
        subject.handle_response('person','no')
        subject.results.should eq "1 'no'"
        
      end
      
    end
    
    context "when there has been a 'meh' vote" do

      it "should reply that there is 1 'no' vote" do
        
        subject.handle_response('person','meh')
        subject.results.should eq "1 'meh'"
        
      end
      
    end
    
    context "when there have been several different votes" do
      
      it "should reply that there is 1 'no' vote" do
        
        subject.handle_response('person_a','yes')
        subject.handle_response('person_b','no')
        subject.handle_response('person_c','meh')
        subject.results.should eq "1 'yes', 1 'no', 1 'meh'"
        
      end
      
    end
    
    context "when there has been multiple votes by the same user" do
      
      it "should count as one vote" do
        
        subject.handle_response('person','no')
        subject.handle_response('person','no')
        subject.handle_response('person','no')
        subject.results.should eq "1 'no'"
        
      end

      it "should only count the last vote" do
        
        subject.handle_response('person','yes')
        subject.handle_response('person','yes')
        subject.handle_response('person','no')
        subject.results.should eq "1 'no'"
        
      end
      
    end
    
  end
  
  
end