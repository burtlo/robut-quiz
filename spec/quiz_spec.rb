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
    "ask scale question 'how much did you like the presentation?', '1..5' for 10 minutes",
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
    
    context "when currently asking a question" do
      
      context "when the response is not an answer to the question" do
        
        it "should not process response for the question" do
          
          subject.stub(:currently_asking_a_question?).and_return(true)
          subject.stub(:is_a_valid_response?).and_return(false)

          subject.should_not_receive(:process_response_for_active_question)
          
          subject.handle time,'person',"@quizmaster ask polar 'Should I continue the presentation?' for 3 minutes"
          
        end
        
      end
      
      context "when the response is an answer to the question" do
        
        it "should process response for the question" do
          subject.stub(:sent_to_me?).and_return(true)
          subject.stub(:currently_asking_a_question?).and_return(true)
          subject.stub(:is_a_valid_response?).and_return(true)

          subject.should_receive(:process_response_for_active_question)
          
          subject.handle time,'person',"@quizmaster ask polar 'Should I continue the presentation?' for 3 minutes"
          
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
        subject.process_the_question time,'person',"ask polar 'Should I continue the presentation?' for 3 minutes"
        
      end
      
    end
    
  end


  describe "#set_current_question" do
    
    before :each do
      subject.stub(:sleep)
    end
    
    let(:question) do
      Robut::Plugin::Quiz::Polar.new 'person',"ask polar 'Should I continue the presentation?' for 3 minutes"
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


describe Robut::Plugin::Quiz::Polar do
  
  subject do
    Robut::Plugin::Quiz::Polar.new 'person',"ask polar 'Should I continue the presentation?' for 3 minutes"
  end
  
  let(:time) { Time.now }
  
  describe "#handle_response" do
    
    context "when the response is a 'yes'" do
      
      it "should store positive response for the user" do
        
        subject.should_receive(:store_positive_response_for).with('person')
        subject.handle_response(time,'person','yes')
        
      end
      
    end

    context "when the response is a 'y'" do
      
      it "should store a positive response for the user" do
        
        subject.should_receive(:store_positive_response_for).with('person')
        subject.handle_response(time,'person','y')

      end
    end
    
    context "when the response is a 'no'" do
      
      it "should store negative response for the user" do
        
        subject.should_receive(:store_negative_response_for).with('person')
        subject.handle_response(time,'person','no')
        
      end
      
    end
    
    context "when the response is a 'n'" do
      
      it "should store negative response for the user" do
      
        subject.should_receive(:store_negative_response_for).with('person')
        subject.handle_response(time,'person','n')
        
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
        
        subject.handle_response(time,'person','yes')
        subject.results.should eq "1 YES vote and 0 NO votes"
        
      end
      
    end
    
    context "when there has been a no vote" do
      
      it "should reply that there is 1 NO vote" do
        
        subject.handle_response(time,'person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end
      
    end
    
    context "when there has been multiple votes by the same user" do
      
      it "should count as one vote" do
        
        subject.handle_response(time,'person','no')
        subject.handle_response(time,'person','no')
        subject.handle_response(time,'person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end

      it "should only count the last vote" do
        
        subject.handle_response(time,'person','yes')
        subject.handle_response(time,'person','yes')
        subject.handle_response(time,'person','no')
        subject.results.should eq "0 YES votes and 1 NO vote"
        
      end
      
    end
    
  end
  
  
end