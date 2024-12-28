# mynotes
this is my first time creating a flutter project project is a simple note taking application which consist of authentication through firebase
it consist of 4 pages at present 
1. Login view
2. Registration View
3. Email Verification
4. Your Notes view
things I've learnt till now are
1.Abstraction :- for the provider and services of firebase authorization, as there should be some kind of integrity in the code do instead of interecting directly with the firebase, I created a provider and services_provider for interaction with the actual user
2.Stream and StreamController:- every thing needs to be in a sequence in order to be served in the next widget as per the user interaction takes place in the notes view
