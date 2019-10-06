"
I represent a full view of a person.
"
Class {
	#name : #FamilyTreePersonView,
	#superclass : #WAComponent,
	#instVars : [
		'parent',
		'person'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreePersonView class >> on: aPerson for: aView [
	^ self new person: aPerson; parent: aView
]

{ #category : #accessing }
FamilyTreePersonView >> parent [
	^ parent
]

{ #category : #accessing }
FamilyTreePersonView >> parent: aView [
	parent := aView
]

{ #category : #accessing }
FamilyTreePersonView >> person [
	^ person
]

{ #category : #accessing }
FamilyTreePersonView >> person: aPerson [
	person := aPerson
]

{ #category : #rendering }
FamilyTreePersonView >> renderContentOn: html [
	self person
		ifNil: [ html text: 'no entry selected' ]
		ifNotNil: [ self renderPersonOn: html ]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonOn: html [
	html heading level: 3; with: self person fullName
]
