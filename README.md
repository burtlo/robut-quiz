# Robut-Quiz

A Plugin for [Robut](https://github.com/justinweiss/robut) that allows you to ask questions and collect the results from all participants within the chatroom.

## Usage

### Yes/No Question (Polar)

```
   user_a  > @robut ask 'Do you want to go to the bar at 4:30?'
   robut   > @user I have enqueued your question
   robut   > @all Question: 'Do you want to go to the bar at 4:30?'
   user_a  > @robut answer YES
   user_b  > @robut answer yes
   user_c  > @robut answer n
   robut   > @all The results are in for 'Do you want to go to the bar at 4:30?':
             2 YES votes and 1 NO vote
```


### Scale/Range Questions

```
   user_a  > @robut ask range 'How much did you like the bar we went to last week?' 1..10
   robut   > @user I have enqueued your question
   robut   > @all Question 'How much did you like the bar we went to last week?' (1..10)
   user_a  > @robut answer 1
   user_b  > @robut answer 5
   user_c  > @robut answer 10
   robut   > @all The results are in for 'How much did you like the bar we went to last week?':
             3 votes with a mean of 5.333333
```

### Choice Questions

```
   user_a  > @robut ask choice 'What drink should I order?' 'PBR', 'Martini', 'Bourbon'
   robut   > @user I have enqueued your question
   robut   > @all Question 'What drink should I order?' (1..10)
   user_a  > @robut answer PBR
   user_b  > @robut answer Martini
   user_c  > @robut answer Martini
   robut   > @all The results are in for 'What drink should I order?':
             1 'PBR', 2 'Martini'
```

## Installation

Install the gem

    gem install robut-quiz
    
Add the plugin to your [Chatfile](https://github.com/justinweiss/robut/blob/master/examples/Chatfile)

    require 'robut_quiz'
    
    Robut::Plugin.plugins << Robut::Plugin::Quiz
