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
	#name : #EventDate,
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

{ #category : #converting }
EventDate class >> dateForYear: aYear month: aMonth day: aDay [
	| aStream |
	aYear ifNil: [ ^ nil ].
	aStream := WriteStream on: String new.
	aYear printOn: aStream.
	aStream nextPut: $-.
	(aMonth ifNil: [ 6 ]) printOn: aStream.
	aStream nextPut: $-.
	(aDay ifNil: [ 15 ]) printOn: aStream.
	^ aStream contents asDate
]

{ #category : #'instance creation' }
EventDate class >> forType: aType year: aYear month: aMonth day: aDay [
	^ self new type: aType; year: aYear; month: aMonth; day: aDay
]

{ #category : #'instance creation' }
EventDate class >> forYear: aYear month: aMonth day: aDay [
	^ self forType: #at year: aYear month: aMonth day: aDay
]

{ #category : #'instance creation' }
EventDate class >> fromString: aString [
	| regex type year month day toYear toMonth toDay eventDate |
	aString ifNil: [ ^ nil ].
	regex := self regexMatcher.
	(regex matches: aString)
		ifFalse: [ ^ nil ].
	type := regex subexpression: 3.
	type = 'bef' ifTrue: [ type := #before ].
	type = 'aft' ifTrue: [ type := #after ].
	type = 'bet' ifTrue: [ type := #between ].
	type = 'abt' ifTrue: [ type := #about ].
	type isSymbol ifFalse: [ type := #at ].
	(regex subexpression: 4) ifNotNil: [ :s | day := s asNumber ].
	(regex subexpression: 5) ifNotNil: [ :s | month := self monthFor: s ].
	(regex subexpression: 7) ifNotNil: [ :s | year := s asNumber ].
	(regex subexpression: 9) ifNotNil: [ :s | toDay := s asNumber ].
	(regex subexpression: 10) ifNotNil: [ :s | toMonth := self monthFor: s ].
	(regex subexpression: 12) ifNotNil: [ :s | toYear := s asNumber ].
	eventDate := self forType: type year: year month: month day: day.
	type = #between
		ifTrue: [ eventDate toYear: toYear; toMonth: toMonth; toDay: toDay ].
	^ eventDate
]

{ #category : #accessing }
EventDate class >> monthFor: aString [
	^ self monthLookup at: aString ifAbsent: [ nil ]
]

{ #category : #accessing }
EventDate class >> monthLookup [
	^ MonthLookup ifNil: [ MonthLookup := { 'jan ' -> 1 . 'feb ' -> 2 . 'mar ' -> 3 . 'apr ' -> 4 . 'may ' -> 5 . 'jun ' -> 6 . 'jul ' -> 7 . 'aug ' -> 8 . 'sep ' -> 9 . 'oct ' -> 10 . 'nov ' -> 11 . 'dec ' -> 12 } asDictionary ]
]

{ #category : #accessing }
EventDate class >> monthNameFor: aMonthNumber [
	^ self monthNames at: aMonthNumber ifAbsent: [ nil ]
]

{ #category : #accessing }
EventDate class >> monthNames [
	^ MonthNames ifNil: [ MonthNames := #('jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec') ]
]

{ #category : #matching }
EventDate class >> regexMatcher [
	^ DateRegex ifNil: [ DateRegex := '((bet|bef|aft) )?(\d\d? )?((jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec) ?)?(\d\d\d\d)?( and (\d\d? )?((jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec) ?)?(\d\d\d\d)?)?' asRegex ]
]

{ #category : #accessing }
EventDate class >> resetMonthLookup [
	MonthLookup := nil
]

{ #category : #matching }
EventDate class >> resetRegexMatcher [
	DateRegex := nil
]

{ #category : #accessing }
EventDate >> day [
	^ day
]

{ #category : #accessing }
EventDate >> day: aNumber [
	day := aNumber
]

{ #category : #accessing }
EventDate >> effectiveDate [
	| start end |
	start := self class dateForYear: self year month: self month day: self day.
	start ifNil: [ ^ nil ].
	self type = #between
		ifFalse: [ ^ start ].
	end := self class dateForYear: self toYear month: self toMonth day: self toDay.
	end ifNil: [ ^ start ].
	^ (start + (end - start / 2)) asDate
]

{ #category : #accessing }
EventDate >> month [
	^ month
]

{ #category : #accessing }
EventDate >> month: aNumber [
	month := aNumber
]

{ #category : #printing }
EventDate >> printOn: aStream [
	| parts |
	parts := OrderedCollection new.
	type = #before ifTrue: [ parts add: 'bef' ].
	type = #after ifTrue: [ parts add: 'aft' ].
	type = #between ifTrue: [ parts add: 'bet' ].
	type = #about ifTrue: [ parts add: 'abt' ].
	day ifNotNil: [ parts add: day asString ].
	month ifNotNil: [ parts add: (self class monthNameFor: month) ].
	year ifNotNil: [ parts add: year asString ].
	type = #between ifTrue: [
		parts add: 'and'.
		toDay ifNotNil: [ parts add: toDay asString ].
		toMonth ifNotNil: [ parts add: (self class monthNameFor: toMonth) ].
		toYear ifNotNil: [ parts add: toYear asString ]
	].
	aStream nextPutAll: (' ' join: parts)
]

{ #category : #accessing }
EventDate >> toDay [
	^ toDay
]

{ #category : #accessing }
EventDate >> toDay: aNumber [
	toDay := aNumber
]

{ #category : #accessing }
EventDate >> toMonth [
	^ toMonth
]

{ #category : #accessing }
EventDate >> toMonth: aNumber [
	toMonth := aNumber
]

{ #category : #accessing }
EventDate >> toYear [
	^ toYear
]

{ #category : #accessing }
EventDate >> toYear: aNumber [
	toYear := aNumber
]

{ #category : #accessing }
EventDate >> type [
	^ type
]

{ #category : #accessing }
EventDate >> type: aTypeSymbol [
	type := aTypeSymbol
]

{ #category : #accessing }
EventDate >> year [
	^ year
]

{ #category : #accessing }
EventDate >> year: aNumber [
	year := aNumber
]
