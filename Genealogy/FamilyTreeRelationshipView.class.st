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
FamilyTreeRelationshipView >> relationship [
	^ relationship
]

{ #category : #accessing }
FamilyTreeRelationshipView >> relationship: aFamily [
	relationship := aFamily
]
