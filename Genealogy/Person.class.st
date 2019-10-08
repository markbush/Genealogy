"
I erpresent a person.
"
Class {
	#name : #Person,
	#superclass : #Object,
	#instVars : [
		'forenames',
		'surname',
		'nickname',
		'gender',
		'birth',
		'death',
		'events',
		'family',
		'relationships'
	],
	#classInstVars : [
		'People'
	],
	#category : #Genealogy
}

{ #category : #accesing }
Person class >> allPeople [
	^ People values sorted: [ :a :b | a fullName <= b fullName ]
]

{ #category : #accesing }
Person class >> allPeopleDict [
	^ People
]

{ #category : #accesing }
Person class >> atId: anId [
	^ People at: anId ifAbsent: [ nil ]
]

{ #category : #accesing }
Person class >> atId: anId add: aPerson [
	^ People at: anId put: aPerson
]

{ #category : #'instance creation' }
Person class >> fromArray: anArray [
	| id person family birthDate birthPlace deathDate deathPlace |
	id := anArray at: 1.
	person := self atId: id.
	person ifNotNil: [ ^ person ].
	person := self new.
	person gender: (anArray at: 3).
	person forenames: (anArray at: 4).
	person surname: (anArray at: 5).
	birthDate := anArray at: 6.
	birthPlace := anArray at: 7.
	(birthDate isNotNil or: [ birthPlace isNotNil ])
		ifTrue: [ person birth: (Event forType: 'birth' on: birthDate at: birthPlace) ].
	deathDate := anArray at: 8.
	deathPlace := anArray at: 9.
	(deathDate isNotNil or: [ deathPlace isNotNil ])
		ifTrue: [ person death: (Event forType: 'death' on: deathDate at: deathPlace) ].
	self atId: id add: person.
	family := Family atId: (anArray at: 2).
	family ifNotNil: [
		person family: family.
		family addChild: person
	].
	^ person
]

{ #category : #'class initialization' }
Person class >> initialize [
	"self initialize"
	People := Dictionary new
]

{ #category : #operations }
Person >> addEvent: anEvent [
	anEvent ifNil: [ ^ self ].
	self events add: anEvent
]

{ #category : #operations }
Person >> addRelationship: aFamily [
	aFamily ifNil: [ ^ self ].
	self relationships add: aFamily
]

{ #category : #accessing }
Person >> auntsAndUncles [
	| auntsAndUncles |
	auntsAndUncles := self parentGeneration.
	self parents do: [ :parent | auntsAndUncles remove: parent ifAbsent: [ nil ] ].
	^ auntsAndUncles
]

{ #category : #accessing }
Person >> birth [
	^ birth
]

{ #category : #accessing }
Person >> birth: anEvent [
	birth := anEvent
]

{ #category : #accessing }
Person >> birthString [
	^ birth
		ifNil: [ '' ]
		ifNotNil: [ birth dateString ]
]

{ #category : #accessing }
Person >> birthWithLocationString [
	^ birth
		ifNil: [ '' ]
		ifNotNil: [ birth dateAndLocationString ]
]

{ #category : #accessing }
Person >> children [
	^ self relationships flatCollect: [ :f | f children ]
]

{ #category : #accessing }
Person >> cousins [
	| parentSiblings |
	parentSiblings := self parentSiblings.
	self parents do: [ :parent | parentSiblings remove: parent ifAbsent: [ nil ] ].
	^ parentSiblings flatCollect: [ :sibling | sibling children ]
]

{ #category : #accessing }
Person >> cousinsWithInlaws [
	| cousinsWithInlaws |
	cousinsWithInlaws := OrderedCollection new.
	self cousins do: [ :cousin |
		cousinsWithInlaws add: cousin.
		(cousin relationships flatCollect: [ :f | f partners ]) do: [ :inlaw |
			(cousinsWithInlaws includes: inlaw)
				ifFalse: [ cousinsWithInlaws add: inlaw ]
		]
	].
	^ cousinsWithInlaws
]

{ #category : #accessing }
Person >> cousinsWithPartners [
	| cousinsWithPartners |
	cousinsWithPartners := OrderedCollection new.
	self cousins do: [ :cousin |
		cousinsWithPartners add: cousin.
		cousin partner ifNotNil: [ cousinsWithPartners add: cousin partner ]
	].
	^ cousinsWithPartners
]

{ #category : #accessing }
Person >> currentRelationship [
	| allCurrent |
	allCurrent := self relationships select: [ :f | f isCurrent ].
	^ allCurrent at: 1 ifAbsent: [ nil ]
]

{ #category : #accessing }
Person >> death [
	^ death
]

{ #category : #accessing }
Person >> death: anEvent [
	death := anEvent
]

{ #category : #accessing }
Person >> deathString [
	^ death
		ifNil: [ '' ]
		ifNotNil: [ death dateString ]
]

{ #category : #accessing }
Person >> deathWithLocationString [
	^ death
		ifNil: [ '' ]
		ifNotNil: [ death dateAndLocationString ]
]

{ #category : #accessing }
Person >> events [
	^ events ifNil: [ events := OrderedCollection new ]
]

{ #category : #accessing }
Person >> family [
	^ family
]

{ #category : #accessing }
Person >> family: aFamily [
	family := aFamily
]

{ #category : #accessing }
Person >> forenames [
	^ forenames
]

{ #category : #accessing }
Person >> forenames: aString [
	forenames := aString
]

{ #category : #accessing }
Person >> fullName [
	| nameParts |
	nameParts := OrderedCollection new.
	self forenames ifNotNil: [ nameParts add: self forenames ].
	self nickname ifNotNil: [ nameParts add: '/' , self nickname , '/' ].
	self surname ifNotNil: [ nameParts add: '(' , self surname , ')' ].
	^ ' ' join: nameParts
]

{ #category : #accessing }
Person >> gender [
	^ gender
]

{ #category : #accessing }
Person >> gender: aString [
	gender := aString
]

{ #category : #accessing }
Person >> grandChildren [
	^ self children flatCollect: [ :child | child children ]
]

{ #category : #accessing }
Person >> grandParents [
	^ self parents flatCollect: [ :parent | parent parents ]
]

{ #category : #accessing }
Person >> greatGrandChildren [
	^ self grandChildren flatCollect: [ :grandChild | grandChild children ]
]

{ #category : #accessing }
Person >> greatGrandParents [
	^ self grandParents flatCollect: [ :grandParent | grandParent parents ]
]

{ #category : #testing }
Person >> isAlive [
	^ self death isNil
]

{ #category : #testing }
Person >> isDeceased [
	^ self death isNotNil
]

{ #category : #accessing }
Person >> nickname [
	^ nickname
]

{ #category : #accessing }
Person >> nickname: aString [
	nickname := aString
]

{ #category : #accessing }
Person >> niecesAndNephews [
	^ self siblings flatCollect: [ :sibling | sibling children ]
]

{ #category : #accessing }
Person >> niecesAndNephewsWithInlaws [
	| niecesAndNephewsWithInlaws |
	niecesAndNephewsWithInlaws := OrderedCollection new.
	self niecesAndNephews do: [ :nieceOrNephew |
		niecesAndNephewsWithInlaws add: nieceOrNephew.
		(nieceOrNephew relationships flatCollect: [ :f | f partners ]) do: [ :inlaw |
			(niecesAndNephewsWithInlaws includes: inlaw)
				ifFalse: [ niecesAndNephewsWithInlaws add: inlaw ]
		]
	].
	^ niecesAndNephewsWithInlaws
]

{ #category : #accessing }
Person >> niecesAndNephewsWithPartners [
	| niecesAndNephewsWithPartners |
	niecesAndNephewsWithPartners := OrderedCollection new.
	self niecesAndNephews do: [ :nieceOrNephew |
		niecesAndNephewsWithPartners add: nieceOrNephew.
		nieceOrNephew partner ifNotNil: [ niecesAndNephewsWithPartners add: nieceOrNephew partner ]
	].
	^ niecesAndNephewsWithPartners
]

{ #category : #accessing }
Person >> parentGeneration [
	| parentSiblings parentGeneration |
	parentSiblings := self parentSiblings.
	parentGeneration := OrderedCollection new.
	parentSiblings do: [ :sibling |
		parentGeneration add: sibling.
		(sibling relationships flatCollect: [ :f | f partners ]) do: [ :inlaw |
			(parentGeneration includes: inlaw)
				ifFalse: [ parentGeneration add: inlaw ]
		]
	].
	^ parentGeneration
]

{ #category : #accessing }
Person >> parentSiblings [
	| parentSiblings |
	parentSiblings := OrderedCollection new.
	(self grandParents flatCollect: [ :grandParent | grandParent children ]) do: [ :parentSibling |
		(parentSiblings includes: parentSibling)
			ifFalse: [ parentSiblings add: parentSibling ]
	].
	^ parentSiblings
]

{ #category : #accessing }
Person >> parents [
	self family
		ifNil: [ ^ OrderedCollection new ]
		ifNotNil: [ ^ self family partners ]
]

{ #category : #accessing }
Person >> partner [
	self currentRelationship
		ifNil: [ ^ nil ]
		ifNotNil: [ ^ (self currentRelationship partners reject: [ :partner | partner = self ]) at: 1 ifAbsent: [ nil ] ]
]

{ #category : #accessing }
Person >> relationships [
	^ relationships ifNil: [ relationships := OrderedCollection new ]
]

{ #category : #accessing }
Person >> siblings [
	self family
		ifNil: [ ^ OrderedCollection new ]
		ifNotNil: [ ^ self family children reject: [ :child | child = self ] ]
]

{ #category : #accessing }
Person >> siblingsWithPartners [
	| siblingsWithPartners |
	siblingsWithPartners := OrderedCollection new.
	self siblings do: [ :sibling |
		siblingsWithPartners add: sibling.
		sibling partner ifNotNil: [ siblingsWithPartners add: sibling partner ]
	].
	^ siblingsWithPartners
]

{ #category : #accessing }
Person >> surname [
	^ surname
]

{ #category : #accessing }
Person >> surname: aString [
	surname := aString
]
