"
I represent a view of a relationship (family).
"
Class {
	#name : #FamilyTreeRelationshipView,
	#superclass : #FamilyTreeView,
	#instVars : [
		'relationship'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyTreeRelationshipView class >> on: aFamily for: aView [
	^ self new relationship: aFamily; parentView: aView
]

{ #category : #accessing }
FamilyTreeRelationshipView >> person [
	^ self parentView selectedPerson
]

{ #category : #accessing }
FamilyTreeRelationshipView >> relationship [
	^ relationship
]

{ #category : #accessing }
FamilyTreeRelationshipView >> relationship: aFamily [
	relationship := aFamily
]

{ #category : #rendering }
FamilyTreeRelationshipView >> renderContentOn: html [
	self renderRelationshipOn: html
]

{ #category : #rendering }
FamilyTreeRelationshipView >> renderRelationshipEvent: anEvent on: html [
	^ html heading
		level: 4;
		with: [
			html text: anEvent type.
			html space.
			html text: anEvent dateAndLocationString
		]
]

{ #category : #rendering }
FamilyTreeRelationshipView >> renderRelationshipOn: html [
	self relationship partners do: [ :partner |
		html div
			class: 'person-partner';
			with: [
				self renderCompactPerson: partner on: html offset: 0
			]
	] without: self person.
	self relationship events do: [ :e | self renderRelationshipEvent: e on: html ].
	self relationship children ifEmpty: [ ^ self ].
	html heading level: 5; with: 'Children'.
	self relationship children do: [ :child |
		self renderCompactPerson: child on: html offset: 1
	]
]
