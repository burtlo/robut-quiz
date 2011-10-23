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
    "ask choice 'What do you want for lunch?', 'pizza', 'sandwich', 'salad' for 1 minute",
    "ask polar 'Should I continue the presentation?' for 3 minutes",
    "ask scale question 'how much did you like the presentation?', '1..5'",
    "ask 'Should I continue the presentation?', 'y|yes', 'n|no' for 1 minutes",
    "ask polar 'Should I continue the presentation?' for 3 minutes"
    
  ].each do |question|
  
    it "should match the question: '#{question}'" do
      
      subject.is_a_valid_question?(question).should be_true
      
    end
    
  end
    
  describe "#handle" do
    
    context "when a question is asked" do
      
      it "should be enqueued to be asked" do
        
        subject.should_receive(:enqueue_the_question).with(time,'person',"ask polar 'Should I continue the presentation?' for 3 minutes")
        subject.handle time,'person',"@quizmaster ask polar 'Should I continue the presentation?' for 3 minutes"
        
      end
      
    end
    
  end
  
  
  
  describe "#process_the_question" do
    
    context "when a polar question is asked" do
      
      it "should find all the components of the question" do
        
        subject.should_receive(:handle_polar).with('person','Should I continue the presentation?','3')
        subject.process_the_question time,'person',"ask polar 'Should I continue the presentation?' for 3 minutes"
        
      end
      
    end
    
  end


  describe "#handle_polar" do
    
    before :each do
      subject.stub(:sleep)
    end
    
    it "should place robut in the mode where it is asking a question" do
      
      subject.should_receive(:start_accepting_responses_for_this_question)
      subject.handle_polar('person','Should I continue the presentation?','3')
      
    end
    
    it "should ask the question" do
      
      subject.should_receive(:reply).with("@person asks 'Should I continue the presentation?' (yes/no)")
      subject.handle_polar('person','Should I continue the presentation?','3')
      
    end
    
    it "should wait until the question time is done" do
      
      subject.should_receive(:sleep).with(180)
      subject.handle_polar('person','Should I continue the presentation?','3')
      
    end
    
    context "when it is done waiting" do
      
      it "should take robut out of the mdoe where it is asking a question" do
        
        subject.should_receive(:stop_accepting_responses_for_this_question)
        subject.handle_polar('person','Should I continue the presentation?','3')
        
      end
      
      it "should process the results for the question" do
        
        subject.should_receive(:process_results_for_question).with("person",'Should I continue the presentation?')
        subject.handle_polar('person','Should I continue the presentation?','3')
        
      end
      
    end
    
  end
    
end