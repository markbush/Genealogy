"
I represent a user of the Family Tree application.
"
Class {
	#name : #FamilyTreeUser,
	#superclass : #Object,
	#instVars : [
		'email',
		'name',
		'picture',
		'accessToken',
		'refreshToken',
		'idToken'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreeUser class >> fromGoogleUserInfo: aDict [
	^ self new
		name: (aDict at: 'name' ifAbsent: [ nil ]);
		email: (aDict at: 'email' ifAbsent: [ nil ]);
		picture: (aDict at: 'picture' ifAbsent: [ nil ])
]

{ #category : #accessing }
FamilyTreeUser >> accessToken [
	^ accessToken
]

{ #category : #accessing }
FamilyTreeUser >> accessToken: aToken [
	accessToken := aToken
]

{ #category : #accessing }
FamilyTreeUser >> email [
	^ email
]

{ #category : #accessing }
FamilyTreeUser >> email: aString [
	email := aString
]

{ #category : #accessing }
FamilyTreeUser >> idToken [
	^ idToken
]

{ #category : #accessing }
FamilyTreeUser >> idToken: aToken [
	idToken := aToken
]

{ #category : #accessing }
FamilyTreeUser >> name [
	^ name
]

{ #category : #accessing }
FamilyTreeUser >> name: aString [
	name := aString
]

{ #category : #accessing }
FamilyTreeUser >> picture [
	^ picture
]

{ #category : #accessing }
FamilyTreeUser >> picture: aString [
	picture := aString
]

{ #category : #accessing }
FamilyTreeUser >> refreshToken [
	^ refreshToken
]

{ #category : #accessing }
FamilyTreeUser >> refreshToken: aToken [
	refreshToken := aToken
]
