"
I represent a compact view of a person.
"
Class {
	#name : #FamilyTreeCompactPersonView,
	#superclass : #WAComponent,
	#instVars : [
		'parent',
		'person'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreeCompactPersonView class >> on: aPerson for: aView [
	^ self new person: aPerson; parent: aView
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> parent [
	^ parent
]

{ #category : #accessing }
FamilyTreeCompactPersonView >> parent: aView [
	parent := aView
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
					html text: self person birthString
				]
		]
]

{ #category : #rendering }
FamilyTreeCompactPersonView >> renderContentOn: html [
	html div
		class: 'person-compact';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parent selectedPerson: self person.
					self parent renderPersonOn: ajaxHtml
				]
		);
		with: [
			self renderNameOn: html.
			self renderDatesOn: html
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
					html text: self person deathString
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
