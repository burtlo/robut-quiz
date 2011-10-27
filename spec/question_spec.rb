require "spec_helper"

describe Robut::Plugin::Quiz::Question do
  
  class TestQuestion
    include Robut::Plugin::Quiz::Question
    
    attr_accessor :question, :parameters, :captured_results
    
  end
  
  let(:question) { "Do you like questions?" }
  let(:question_with_params) { "'#{question}', 'yes', 'no' 'maybe'" }
  
  subject { TestQuestion.new "sender", question_with_params }
  
  describe "#to_s" do
    
    it "should be the question that was asked" do
      subject.to_s.should == question
    end
    
  end
  
  describe "#ask" do
    
    it "should be the default statement to ask question" do
      subject.ask.should == "@all Question '#{question}'"
    end
    
  end
  
  describe "#process_question" do
    
    context "when a question with parameters" do
      
      it "should find the question" do
        subject.process_question question_with_params
        subject.question.should == question
      end
      
      it "should find the parameters" do
        subject.process_question question_with_params
        subject.parameters.should == [ 'yes', 'no', 'maybe' ]
      end
      
    end
    
    context "when only a question has been provided" do
      
      it "should find the question" do
        subject.process_question "'Ask more questions?'"
        subject.question.should == 'Ask more questions?'
      end
      
    end
    
  end
  
  describe "subject" do
    
  end
  
end