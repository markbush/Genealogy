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
Event class >> forType: aType on: aDateString at: aLocation [
	^ self new
		type: aType;
		date: aDateString;
		location: aLocation
]

{ #category : #accessing }
Event >> date [
	^ date
]

{ #category : #accessing }
Event >> date: aDateString [
	date := aDateString
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
