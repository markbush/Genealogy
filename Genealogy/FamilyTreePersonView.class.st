"
I represent a full view of a person.
"
Class {
	#name : #FamilyTreePersonView,
	#superclass : #WAComponent,
	#instVars : [
		'parentView',
		'person'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreePersonView class >> on: aPerson for: aView [
	^ self new person: aPerson; parentView: aView
]

{ #category : #accessing }
FamilyTreePersonView >> parentView [
	^ parentView
]

{ #category : #accessing }
FamilyTreePersonView >> parentView: aView [
	parentView := aView
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
FamilyTreePersonView >> renderChildrenOn: html [
	html heading level: 3; with: 'Children'.
	self person children do: [ :child |
		self renderCompactPerson: child on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderCompactPerson: aPerson on: html [
	html tbsRow
		class: 'selectable';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parentView selectedPerson: aPerson.
					self parentView renderPersonOn: ajaxHtml
				]
		);
		with: [
			html tbsColumn
				mediumOffset: 1;
				with: [
					html text: aPerson fullName.
					self renderDatesForPerson: aPerson on: html
				]
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderContentOn: html [
	self person
		ifNil: [ html text: 'no entry selected' ]
		ifNotNil: [ self renderPersonOn: html ]
]

{ #category : #rendering }
FamilyTreePersonView >> renderDatesForPerson: aPerson on: html [
	html text: ' [b: '.
	html text: aPerson birthString.
	html text: ', d: '.
	html text: aPerson deathString.
	html text: ']'
]

{ #category : #rendering }
FamilyTreePersonView >> renderGrandParentsOn: html [
	html heading level: 3; with: 'Grandparents'.
	self person grandParents do: [ :grandParent |
		self renderCompactPerson: grandParent on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderMainInfoOn: html [
	html tbsRow with: [
		html text: 'Born: '.
		html text: self person birthString
	].
	html tbsRow with: [
		html text: 'Died: '.
		html text: self person deathString
	].

]

{ #category : #rendering }
FamilyTreePersonView >> renderParentsOn: html [
	html heading level: 3; with: 'Parents'.
	self person parents do: [ :parent |
		self renderCompactPerson: parent on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonOn: html [
	html heading level: 3; with: self person fullName.
	self renderMainInfoOn: html.
	self renderGrandParentsOn: html.
	self renderParentsOn: html.
	self renderSiblingsOn: html.
	self renderRelationshipsOn: html
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationship: aFamily on: html [
	aFamily partners reject: [ :p | p = self person ] thenDo: [ :partner |
		html heading
			level: 4;
			class: 'selectable';
			onClick: (
				((html jQuery id: #main) load)
					html: [ :ajaxHtml |
						self parentView selectedPerson: partner.
						self parentView renderPersonOn: ajaxHtml
					]
			);
			with: [
				html text: partner fullName.
				self renderDatesForPerson: partner on: html
			].
		html heading level: 5; with: 'Children'.
		partner children do: [ :child |
			self renderCompactPerson: child on: html
		]
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationshipsOn: html [
	html heading level: 3; with: 'Relationships'.
	self person relationships do: [ :family |
		self renderRelationship: family on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderSiblingsOn: html [
	html heading level: 3; with: 'Siblings'.
	self person siblings do: [ :sibling |
		self renderCompactPerson: sibling on: html
	]
]
