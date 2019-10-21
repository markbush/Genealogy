"
I represent a compact view of a person.
"
Class {
	#name : #FamilyTreePersonCompactView,
	#superclass : #FamilyTreeView,
	#instVars : [
		'person'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreePersonCompactView class >> on: aPerson for: aView [
	^ self new person: aPerson; parentView: aView
]

{ #category : #accessing }
FamilyTreePersonCompactView >> person [
	^ person
]

{ #category : #accessing }
FamilyTreePersonCompactView >> person: aPerson [
	person := aPerson
]

{ #category : #rendering }
FamilyTreePersonCompactView >> renderCompactPersonOn: html [
	html span
		class: 'selectable';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parentView selectedPerson: self person.
					self parentView renderPersonOn: ajaxHtml
				]
		);
		with: [
			html text: self person fullName.
			self renderDatesForPersonOn: html
		]
]

{ #category : #rendering }
FamilyTreePersonCompactView >> renderContentOn: html [
	self renderCompactPersonOn: html
]

{ #category : #rendering }
FamilyTreePersonCompactView >> renderDatesForPersonOn: html [
	html text: ' [b: '.
	html text: self person birthString.
	(self person isAlive and: [ self person age isNotNil ])
		ifTrue: [
			html text: ' (' , self person age truncated printString , ')'
		].
	html text: ', d: '.
	html text: self person deathString.
	(self person isDeceased and: [ self person age isNotNil ])
		ifTrue: [
			html text: ' (' , self person age truncated printString , ')'
		].
	html text: ']'
]
