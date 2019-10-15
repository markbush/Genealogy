"
I represent an event in a person's life.
"
Class {
	#name : #Event,
	#superclass : #Object,
	#instVars : [
		'type',
		'date',
		'location'
	],
	#category : #Genealogy
}

{ #category : #'instance creation' }
Event class >> forType: aType on: anEventDate at: aLocation [
	^ self new
		type: aType;
		date: anEventDate;
		location: aLocation
]

{ #category : #accessing }
Event >> date [
	^ date
]

{ #category : #accessing }
Event >> date: anEventDate [
	date := anEventDate
]

{ #category : #accessing }
Event >> dateAndLocationString [
	| s |
	date ifNil: [ ^ '' ].
	s := WriteStream on: String new.
	s nextPutAll: self dateString.
	location ifNotNil: [
		s nextPutAll: ' ('.
		s nextPutAll: location.
		s nextPutAll: ')'
	].
	^ s contents
]

{ #category : #accessing }
Event >> dateString [
	^ date
		ifNil: [ '' ]
		ifNotNil: [ date asString ]
]

{ #category : #accessing }
Event >> effectiveDate [
	"If no date, use 01/01/0001"
	self date ifNil: [ ^ nil "('1-1-101' asDate - 100 years - 24 days) asDate" ].
	^ date effectiveDate
]

{ #category : #accessing }
Event >> location [
	^ location
]

{ #category : #accessing }
Event >> location: aString [
	location := aString
]

{ #category : #accessing }
Event >> type [
	^ type
]

{ #category : #accessing }
Event >> type: aString [
	type := aString
]
