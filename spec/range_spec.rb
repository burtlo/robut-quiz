require_relative 'spec_helper'

describe Robut::Plugin::Quiz::Range do
  
  subject do
    Robut::Plugin::Quiz::Range.new 'person',"ask range for 3 minutes 'Should I continue the presentation?'"
  end
  
  describe "#start_value" do
    
    context "when no range has been specified" do
      
      it "should default to the value 1" do
        subject.start_value.should == 1
      end
      
    end
    
  end
  
  describe "#highest_value" do
    
    context "when no range has been specified" do

      it "should default to the value of 5" do
        subject.highest_value.should == 5
      end
      
    end
    
  end
  
  describe "#within_range?" do
    
    context "when the value is within range" do
    
      it "should respond with true" do
        subject.within_range?(3).should be_true
      end
        
    end
    
    context "when the value is not within range" do
      
      it "should respond with false" do
        subject.within_range?(6).should be_false
      end
      
    end
    
  end
  
  describe "#handle_response" do
    
    context "with a valid response" do
      
      it "should return true" do
        subject.should_receive(:store_range_response_for).with("sender","1")
        subject.handle_response("sender","1").should be_true
      end
      
    end
    
  end
  
  describe Robut::Plugin::Quiz::Range::Averages do
    
    subject do
      array = [1,1,2,2,2,3,4,5]
      array.extend Robut::Plugin::Quiz::Range::Averages
    end
    
    
    describe "#sum" do
      
      it "should return the correct value" do
        subject.sum.should == 20
      end
      
    end
    
    describe "#mean" do
      
      it "should return the correct value" do
        subject.mean.should == 2.5
      end
      
    end
    
    describe "#mode" do
      
      it "should return the correct value" do
        subject.mode.should == 2
      end
      
    end
    
  end
  
end
