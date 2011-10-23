# Robut-Quiz

A Plugin for [Robut](https://github.com/justinweiss/robut) that allows you to ask questions and collect the results from all participants within the chatroom.

## Usage

### Polar Question (Yes/No)

```
   user_a  > @robut ask 'Do you want to go to the bar at 4:30?' for 5 minutes.
   robut   > @user I have enqueued your question
   robut   > @all Question: 'Do you want to go to the bar at 4:30?'
   user_a  > @robut answer YES
   user_b  > @robut answer yes
   user_c  > @robut answer n
   robut   > @all The results are in for 'Do you want to go to the bar at 4:30?:'
             2 YES votes and 1 NO vote
```

## Installation

Install the gem

    gem install robut-quiz
    
Add the plugin to your [Chatfile](https://github.com/justinweiss/robut/blob/master/examples/Chatfile)

    require 'robut_quiz'
    
    Robut::Plugin.plugins << Robut::Plugin::Quiz
