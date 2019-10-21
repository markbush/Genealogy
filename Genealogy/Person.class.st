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
		'relationships',
		'notes'
	],
	#classInstVars : [
		'People'
	],
	#category : #Genealogy
}

{ #category : #'date operations' }
Person class >> ageFrom: aDate to: laterDate [
	"Accurate enough representation of age (rounded to nearest .1)"
	^ ((laterDate - aDate) days / 365.25) round: 1
]

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
	| id person forenames family birthDate birthPlace deathDate deathPlace |
	id := anArray at: 1.
	person := self atId: id.
	person ifNotNil: [ ^ person ].
	person := self new.
	person gender: (anArray at: 3).
	forenames := (anArray at: 4).
	(forenames isNotNil and: [ forenames includes: $( ])
		ifFalse: [ person forenames: forenames ]
		ifTrue: [ | nicknameMatcher |
			nicknameMatcher := '(.*) \((.*)\)' asRegex.
			(nicknameMatcher matches: forenames)
				ifFalse: [ person forenames: forenames ]
				ifTrue: [
					person forenames: (nicknameMatcher subexpression: 2).
					person nickname: (nicknameMatcher subexpression: 3)
				]
		].
	person surname: (anArray at: 5).
	birthDate := anArray at: 6.
	birthDate ifNotNil: [ birthDate := EventDate fromString: birthDate ].
	birthPlace := anArray at: 7.
	(birthDate isNotNil or: [ birthPlace isNotNil ])
		ifTrue: [ person birth: (Event forType: 'birth' on: birthDate at: birthPlace) ].
	deathDate := anArray at: 8.
	deathDate ifNotNil: [ deathDate := EventDate fromString: deathDate ].
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

{ #category : #data }
Person class >> resetDataFrom: aFilename [
	| fileStream csv |
	"self resetDataFrom: '/Users/bush/Downloads/family-data.csv'"
	self initialize.
	Family initialize.
	fileStream := aFilename asFileReference readStream.
	csv := NeoCSVReader on: fileStream.
	csv do: [ :record | | person1 person2 family |
		person1 := nil.
		person2 := nil.
		(record at: 1) ifNotNil: [
			person1 := self fromArray: (record copyFrom: 1 to: 9)
		].
		(record at: 12) ifNotNil: [
			person2 := self fromArray: (record copyFrom: 12 to: 20)
		].
		(record at: 10) ifNotNil: [
			family := Family fromArray: (record copyFrom: 10 to: 11).
			person1 addRelationship: family.
			person2 ifNotNil: [ person2 addRelationship: family ].
			family addPartner: person1.
			family addPartner: person2
		]
	].
	Transcript
		show: 'Loaded:'; cr;
		show: self allPeople size; show: ' people'; cr;
		show: Family allFamilies size; show: ' families'; cr
]

{ #category : #operations }
Person >> addEvent: anEvent [
	anEvent ifNil: [ ^ self ].
	self events add: anEvent
]

{ #category : #accessing }
Person >> addNote: aNote [
	self notes add: aNote
]

{ #category : #operations }
Person >> addRelationship: aFamily [
	aFamily ifNil: [ ^ self ].
	self relationships add: aFamily
]

{ #category : #accessing }
Person >> age [
	| birthDate deathDate age |
	self birth ifNil: [ ^ nil ].
	birthDate := self birth effectiveDate.
	birthDate ifNil: [ ^ nil ].
	age := self class ageFrom: birthDate to: Date today.
	self isAlive ifTrue: [
		age < 100
			ifTrue: [ ^ age ]
			ifFalse: [ ^ nil ] "Maybe deseased without death recorded?"
	].
	deathDate := self death effectiveDate.
	deathDate ifNil: [ ^ nil ]. "Cannot determine death properly."
	^ self class ageFrom: birthDate to: deathDate
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
Person >> birthLocation [
	^ birth
		ifNil: [ '' ]
		ifNotNil: [ birth location ]
]

{ #category : #accessing }
Person >> birthLocation: aString [
	birth
		ifNil: [ birth := Event forType: #birth on: nil at: aString ]
		ifNotNil: [ birth location: aString ]
]

{ #category : #accessing }
Person >> birthString [
	^ birth
		ifNil: [ '' ]
		ifNotNil: [ birth dateString ]
]

{ #category : #accessing }
Person >> birthString: aString [
	| date |
	date := EventDate fromString: aString.
	(date isNil and: [ aString isEmptyOrNil not ])
		ifTrue: [ ^ self ].
	birth
		ifNil: [ birth := Event forType: #birth on: date at: nil ]
		ifNotNil: [ birth date: date ]
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
Person >> deathLocation [
	^ death
		ifNil: [ '' ]
		ifNotNil: [ death location ]
]

{ #category : #accessing }
Person >> deathLocation: aString [
	death
		ifNil: [ death := Event forType: #death on: nil at: aString ]
		ifNotNil: [ death location: aString ]
]

{ #category : #accessing }
Person >> deathString [
	^ death
		ifNil: [ '' ]
		ifNotNil: [ death dateString ]
]

{ #category : #accessing }
Person >> deathString: aString [
	| date |
	date := EventDate fromString: aString.
	(date isNil and: [ aString isEmptyOrNil not ])
		ifTrue: [ ^ self ].
	death
		ifNil: [ death := Event forType: #death on: date at: nil ]
		ifNotNil: [ death date: date ]
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
	self forenames isEmptyOrNil ifFalse: [ nameParts add: self forenames ].
	self nickname isEmptyOrNil ifFalse: [ nameParts add: '/' , self nickname , '/' ].
	self surname isEmptyOrNil ifFalse: [ nameParts add: '(' , self surname , ')' ].
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
	^ self death isNil or: [ self death dateString isEmptyOrNil ]
]

{ #category : #testing }
Person >> isDeceased [
	^ self isAlive not
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
Person >> notes [
	^ notes ifNil: [ notes := OrderedCollection new ]
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
Person >> removeNote: aNote [
	self notes remove: aNote ifAbsent: [ nil ]
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
