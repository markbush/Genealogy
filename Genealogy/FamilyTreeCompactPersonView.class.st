"
I represent a compact view of a person.
"
Class {
	#name : #FamilyTreeCompactPersonView,
	#superclass : #FamilyTreeView,
	#instVars : [
		'person',
		'viewId'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreeCompactPersonView class >> on: aPerson for: aView [
	^ self new person: aPerson; parentView: aView
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> person [
	^ person
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> person: aPerson [
	person := aPerson
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderBirthOn: html [
	html tbsRow
		class: 'person-birth';
		with: [
			html tbsColumn
				mediumOffset: 1;
				mediumSize: 10;
				with: [
					html text: 'b: '.
					html text: self person birthString.
					(self person isAlive and: [ self person age isNotNil ])
						ifTrue: [
							html text: ' (' , self person age truncated printString , ')'
						]
				]
		]
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderContentOn: html [
	self viewId: html nextId.
	html div
		id: self viewId;
		with: [
			self renderPersonOn: html
		]
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderDatesOn: html [
	self renderBirthOn: html.
	self renderDeathOn: html
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderDeathOn: html [
	html tbsRow
		class: 'person-death';
		with: [
			html tbsColumn
				mediumOffset: 1;
				mediumSize: 10;
				with: [
					html text: 'd: '.
					html text: self person deathString.
					(self person isDeceased and: [ self person age isNotNil ])
						ifTrue: [
							html text: ' (' , self person age truncated printString , ')'
						]
				]
		]
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderNameOn: html [
	html tbsRow
		class: 'person-name';
		with: [
			html tbsColumn
				mediumOffset: 1;
				mediumSize: 10;
				with: self person fullName
		]
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderPersonOn: html [
	html div
		class: 'person-compact selectable';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parentView selectedPerson: self person.
					self parentView selectedView: self.
					self parentView renderPersonOn: ajaxHtml
				]
		);
		with: [
			self renderNameOn: html.
			self renderDatesOn: html
		]
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> viewId [
	^ viewId
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> viewId: anId [
	viewId := anId
]
