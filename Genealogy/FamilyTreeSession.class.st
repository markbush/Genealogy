"
I represent a session for the Family Tree application.

I hold information about the currently logged in user.
"
Class {
	#name : #FamilyTreeSession,
	#superclass : #WASession,
	#instVars : [
		'user',
		'accessToken',
		'refreshToken',
		'idToken'
	],
	#category : #Genealogy
}

{ #category : #accessing }
FamilyTreeSession >> accessToken [
	^ accessToken
]

{ #category : #accessing }
FamilyTreeSession >> accessToken: aToken [
	accessToken := aToken
]

{ #category : #accessing }
FamilyTreeSession >> idToken [
	^ idToken
]

{ #category : #accessing }
FamilyTreeSession >> idToken: aToken [
	idToken := aToken
]

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
	user := nil.
	accessToken := nil.
	idToken := nil.
	refreshToken := nil
]

{ #category : #accessing }
FamilyTreeSession >> refreshToken [
	^ refreshToken
]

{ #category : #accessing }
FamilyTreeSession >> refreshToken: aToken [
	refreshToken := aToken
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
