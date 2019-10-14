"
I represent a family unit.
"
Class {
	#name : #Family,
	#superclass : #Object,
	#instVars : [
		'partners',
		'children',
		'events',
		'status',
		'current'
	],
	#classInstVars : [
		'Families'
	],
	#category : #Genealogy
}

{ #category : #accessing }
Family class >> allFamilies [
	^ Families values
]

{ #category : #accessing }
Family class >> allFamiliesDict [
	^ Families
]

{ #category : #accessing }
Family class >> atId: anId [
	^ Families at: anId ifAbsent: [ nil ]
]

{ #category : #accessing }
Family class >> atId: anId add: aFamily [
	^ Families at: anId put: aFamily
]

{ #category : #'instance creation' }
Family class >> fromArray: anArray [
	| familyId family marriageDate |
	familyId := anArray at: 1.
	family := self atId: familyId.
	family ifNotNil: [ ^ family ].
	family := self new.
	marriageDate := anArray at: 2.
	marriageDate ifNotNil: [
		family addEvent: (Event forType: 'marriage' on: marriageDate at: nil)
	].
	self atId: familyId add: family.
	^ family
]

{ #category : #'class initialization' }
Family class >> initialize [
	"self initialize"
	Families := Dictionary new
]

{ #category : #updating }
Family >> addChild: aPerson [
	aPerson ifNil: [ ^ self ].
	(self children includes: aPerson)
		ifFalse: [ self children add: aPerson ]
]

{ #category : #updating }
Family >> addEvent: anEvent [
	anEvent ifNil: [ ^ self ].
	(self events includes: anEvent)
		ifFalse: [ self events add: anEvent ]
]

{ #category : #updating }
Family >> addPartner: aPerson [
	aPerson ifNil: [ ^ self ].
	(self partners includes: aPerson) ifTrue: [ ^ self ].
	self partners add: aPerson.
	self isCurrent ifFalse: [ ^ self ].
	aPerson relationships reject: [ :f | f = self ] thenDo: [ :f | f current: false ]
]

{ #category : #accessing }
Family >> children [
	^ children ifNil: [ children := OrderedCollection new ]
]

{ #category : #accessing }
Family >> current [
	^ current ifNil: [ current := false ]
]

{ #category : #accessing }
Family >> current: aBoolean [
	current := aBoolean.
	aBoolean ifFalse: [ ^ self ].
	self partners do: [ :partner |
		partner relationships reject: [ :f | f = self ] thenDo: [ :f | f current: false ]
	]
]

{ #category : #accessing }
Family >> events [
	^ events ifNil: [ events := OrderedCollection new ]
]

{ #category : #testing }
Family >> isCurrent [
	^ self current
]

{ #category : #accessing }
Family >> partners [
	^ partners ifNil: [ partners := OrderedCollection new ]
]

{ #category : #updating }
Family >> removeChild: aPerson [
	self children remove: aPerson ifAbsent: [ nil ]
]

{ #category : #updating }
Family >> removeEvent: anEvent [
	self events remove: anEvent ifAbsent: [ nil ]
]

{ #category : #updating }
Family >> removePartner: aPerson [
	self partners remove: aPerson ifAbsent: [ nil ]
]

{ #category : #accessing }
Family >> status [
	^ status
]

{ #category : #accessing }
Family >> status: aString [
	status := aString
]
