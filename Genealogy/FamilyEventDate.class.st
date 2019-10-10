"
I represent an event date.

My type can be:
#at - the components set in #year, #month, #day are correct
#before - the components set in #year, #month, #day are an upper bound
#after - the components set in #year, #month, #day are a lower bound
#between - the components set in #year, #month, #day are a lower bound and in #toYear, #toMonth, #toDay are an upper bound

The effective date is nil unless the year is known.
If all components are known, then it is the date itself.
If just month and year are known, it is the 15th of that month.
If just the year is known, it is the 1st of June of that year.
For #between, it is the mid point between the bounds.
"
Class {
	#name : #FamilyEventDate,
	#superclass : #Object,
	#instVars : [
		'type',
		'year',
		'month',
		'day',
		'toYear',
		'toMonth',
		'toDay'
	],
	#classVars : [
		'DateRegex',
		'MonthLookup',
		'MonthNames'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
FamilyEventDate class >> forType: aType year: aYear month: aMonth day: aDay [
	^ self new type: aType; year: aYear; month: aMonth; day: aDay
]

{ #category : #'instance creation' }
FamilyEventDate class >> forYear: aYear month: aMonth day: aDay [
	^ self forType: #at year: aYear month: aMonth day: aDay
]

{ #category : #'instance creation' }
FamilyEventDate class >> fromString: aString [
	| regex type year month day toYear toMonth toDay eventDate |
	aString ifNil: [ ^ nil ].
	regex := self regexMatcher.
	(regex matches: aString)
		ifFalse: [ ^ nil ].
	type := regex subexpression: 3.
	type = 'bef' ifTrue: [ type := #before ].
	type = 'aft' ifTrue: [ type := #after ].
	type = 'bet' ifTrue: [ type := #between ].
	type isSymbol ifFalse: [ type := #at ].
	(regex subexpression: 4) ifNotNil: [ :s | day := s asNumber ].
	(regex subexpression: 5) ifNotNil: [ :s | month := self monthFor: s ].
	(regex subexpression: 6) ifNotNil: [ :s | year := s asNumber ].
	(regex subexpression: 8) ifNotNil: [ :s | toDay := s asNumber ].
	(regex subexpression: 9) ifNotNil: [ :s | toMonth := self monthFor: s ].
	(regex subexpression: 10) ifNotNil: [ :s | toYear := s asNumber ].
	eventDate := self forType: type year: year month: month day: day.
	type = #between
		ifTrue: [ eventDate toYear: toYear; toMonth: toMonth; toDay: toDay ].
	^ eventDate
]

{ #category : #accessing }
FamilyEventDate class >> monthFor: aString [
	^ self monthLookup at: aString ifAbsent: [ nil ]
]

{ #category : #accessing }
FamilyEventDate class >> monthLookup [
	^ MonthLookup ifNil: [ MonthLookup := { 'jan ' -> 1 . 'feb ' -> 2 . 'mar ' -> 3 . 'apr ' -> 4 . 'may ' -> 5 . 'jun ' -> 6 . 'jul ' -> 7 . 'aug ' -> 8 . 'sep ' -> 9 . 'oct ' -> 10 . 'nov ' -> 11 . 'dec ' -> 12 } asDictionary ]
]

{ #category : #accessing }
FamilyEventDate class >> monthNameFor: aMonthNumber [
	^ self monthNames at: aMonthNumber ifAbsent: [ nil ]
]

{ #category : #accessing }
FamilyEventDate class >> monthNames [
	^ MonthNames ifNil: [ MonthNames := #('jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec') ]
]

{ #category : #matching }
FamilyEventDate class >> regexMatcher [
	^ DateRegex ifNil: [ DateRegex := '((bet|bef|aft) )?(\d\d? )?([a-z]+ ?)?(\d\d\d\d)?( and (\d\d? )?([a-z]+ ?)?(\d\d\d\d)?)?' asRegex ]
]

{ #category : #accessing }
FamilyEventDate >> day [
	^ day
]

{ #category : #accessing }
FamilyEventDate >> day: aNumber [
	day := aNumber
]

{ #category : #accessing }
FamilyEventDate >> month [
	^ month
]

{ #category : #accessing }
FamilyEventDate >> month: aNumber [
	month := aNumber
]

{ #category : #printing }
FamilyEventDate >> printOn: aStream [
	| parts |
	parts := OrderedCollection new.
	type = #before ifTrue: [ parts add: 'bef' ].
	type = #after ifTrue: [ parts add: 'aft' ].
	type = #between ifTrue: [ parts add: 'bet' ].
	day ifNotNil: [ parts add: day asString ].
	month ifNotNil: [ parts add: (self class monthNameFor: month) ].
	year ifNotNil: [ parts add: year asString ].
	type = #between ifTrue: [
		parts add: 'and'.
		toDay ifNotNil: [ parts add: toDay asString ].
		toMonth ifNotNil: [ parts add: (self class monthNameFor: toMonth) ].
		toYear ifNotNil: [ parts add: toYear asString ]
	].
	^ aStream nextPutAll: (' ' join: parts)
]

{ #category : #accessing }
FamilyEventDate >> toDay [
	^ toDay
]

{ #category : #accessing }
FamilyEventDate >> toDay: aNumber [
	toDay := aNumber
]

{ #category : #accessing }
FamilyEventDate >> toMonth [
	^ toMonth
]

{ #category : #accessing }
FamilyEventDate >> toMonth: aNumber [
	toMonth := aNumber
]

{ #category : #accessing }
FamilyEventDate >> toYear [
	^ toYear
]

{ #category : #accessing }
FamilyEventDate >> toYear: aNumber [
	toYear := aNumber
]

{ #category : #accessing }
FamilyEventDate >> type [
	^ type
]

{ #category : #accessing }
FamilyEventDate >> type: aTypeSymbol [
	type := aTypeSymbol
]

{ #category : #accessing }
FamilyEventDate >> year [
	^ year
]

{ #category : #accessing }
FamilyEventDate >> year: aNumber [
	year := aNumber
]
