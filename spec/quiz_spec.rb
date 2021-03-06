require_relative 'spec_helper'

describe Robut::Plugin::Quiz do
  
  subject { 
    connection = double("connection")
    connection.stub_chain(:config, :nick) { "quizmaster" }
    connection.stub(:store).and_return(store)
    connection.stub(:reply).and_return(nil)
    Robut::Plugin::Quiz.new connection 
  }
  
  let!(:store) { {} }
  
  let(:time) { Time.now }
  
  [ 
    "ask 'Should I continue the presentation?'",
    "ask for 3 minutes 'Should I continue the presentation?'",
    "ask polar for 3 minutes 'Should I continue the presentation?'",
    "ask choice 1 minute 'What do you want for lunch?', 'pizza', 'sandwich', 'salad'",
    "ask scale question for 10 minutes 'how much did you like the presentation?', '1..5'"
    
  ].each do |question|
  
    it "should match the question: '#{question}'" do
      
      subject.is_a_valid_question?(question).should be_true
      
    end
    
  end
    
  describe "#handle" do
    
    context "when a question is asked" do
      
      it "should be enqueued to be asked" do
        
        subject.should_receive(:enqueue_the_question).with('person',"ask polar 'Should I continue the presentation?' for 3 minutes")
        subject.handle time,'person',"@quizmaster ask polar 'Should I continue the presentation?' for 3 minutes"
        
      end
      
    end
    
    context "when currently asking a question" do
      
      context "when the response is not an answer to the question" do
        
        it "should not process response for the question" do
          
          subject.stub(:currently_asking_a_question?).and_return(true)
          subject.stub(:is_a_valid_response?).and_return(false)

          subject.should_not_receive(:process_response_for_active_question)
          
          subject.handle time,'person',"@quizmaster ask polar for 3 minutes 'Should I continue the presentation?'"
          
        end
        
      end
      
      context "when the response is an answer to the question" do
        
        it "should process response for the question" do
          subject.stub(:sent_to_me?).and_return(true)
          subject.stub(:currently_asking_a_question?).and_return(true)
          subject.stub(:is_a_valid_response?).and_return(true)

          subject.should_receive(:process_response_for_active_question)
          
          subject.handle time,'person',"@quizmaster ask polar for 3 minutes 'Should I continue the presentation?'"
          
        end
        
      end
      
    end
    
  end
  
  
  
  describe "#process_the_question" do
    
    context "when a polar question is asked" do
      
      it "should find all the components of the question" do
        
        expected_question = Robut::Plugin::Quiz::Polar.new 'person',"ask polar 'Should I continue the presentation?' for 3 minutes"
        
        subject.should_receive(:create_the_question_based_on_type).and_return(expected_question)
        
        subject.should_receive(:set_current_question).with(expected_question,'3')
        subject.process_the_question 'person',"ask polar for 3 minutes 'Should I continue the presentation?'"
        
      end
      
    end
    
  end


  describe "#set_current_question" do
    
    before :each do
      subject.stub(:sleep)
    end
    
    let(:question) do
      Robut::Plugin::Quiz::Polar.new 'person',"'Should I continue the presentation?'"
    end
    
    it "should place robut in the mode where it is asking a question" do
      
      subject.should_receive(:start_accepting_responses_for_this_question)
      subject.set_current_question(question,'3')
      
    end
    
    it "should ask the question" do
      
      question.should_receive(:ask)
      subject.set_current_question(question,'3')
      
    end
    
    it "should wait until the question time is done" do
      
      subject.should_receive(:sleep).with(180)
      subject.set_current_question(question,'3')
      
    end
    
    context "when it is done waiting" do
      
      it "should take robut out of the mdoe where it is asking a question" do
        
        subject.should_receive(:stop_accepting_responses_for_this_question)
        subject.set_current_question(question,'3')
        
      end
      
      it "should process the results for the question" do
        
        question.should_receive(:results)
        subject.set_current_question(question,'3')
        
      end
      
    end
    
  end
    
end