//we doing because we shouldnt expose firebase's user to the UI 
//Login Exception

class UserNotFoundAuthException implements Exception{}

class WrongPasswordAuthException implements Exception{}

//Register Exception

class WeakPasswordAuthException implements Exception{}

class EmailAlreadyInUseAuthException implements Exception{}

class InvalidEmailAuthException implements Exception{}

//Generic Exception 

class GenericAuthException implements Exception{}

class UserNotLoggedInException implements Exception{}