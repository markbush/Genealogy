"
I represent a session for the Family Tree application.

I hold information about the currently logged in user.
"
Class {
	#name : #FamilyTreeSession,
	#superclass : #WASession,
	#instVars : [
		'user'
	],
	#category : #Genealogy
}

{ #category : #testing }
FamilyTreeSession >> isLoggedIn [
	^ self user isNotNil
]

{ #category : #operations }
FamilyTreeSession >> login: aUser [
	user := aUser
]

{ #category : #operations }
FamilyTreeSession >> logout [
	user := nil
]

{ #category : #'parent/child' }
FamilyTreeSession >> unregistered [
	super unregistered.
	self logout
]

{ #category : #accessing }
FamilyTreeSession >> user [
	^ user
]
