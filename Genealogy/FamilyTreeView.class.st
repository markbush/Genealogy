"
I represent a generic family tree view.

I contain common code for family tree components.
"
Class {
	#name : #FamilyTreeView,
	#superclass : #WAComponent,
	#instVars : [
		'parentView',
		'selectedView',
		'editField',
		'editValue'
	],
	#category : #Genealogy
}

{ #category : #accessing }
FamilyTreeView >> editField [
	^ editField
]

{ #category : #accessing }
FamilyTreeView >> editField: aPersonField [
	editField := aPersonField
]

{ #category : #accessing }
FamilyTreeView >> editValue [
	^ editValue
]

{ #category : #accessing }
FamilyTreeView >> editValue: aString [
	editValue := aString
]

{ #category : #accessing }
FamilyTreeView >> parentView [
	^ parentView
]

{ #category : #accessing }
FamilyTreeView >> parentView: aView [
	parentView := aView
]

{ #category : #rendering }
FamilyTreeView >> renderTo: html linkForModal: aModalSymbol titleId: titleId title: title fieldSelector: aSelector inputId: inputId valueBlock: aBlock [
	self renderTo: html linkForModal: aModalSymbol titleId: titleId title: title fieldSelector: aSelector inputId: inputId valueBlock: aBlock icon: #iconEdit
]

{ #category : #rendering }
FamilyTreeView >> renderTo: html linkForModal: aModalSymbol titleId: titleId title: title fieldSelector: aSelector inputId: inputId valueBlock: aBlock icon: anIconSelector [
	html anchor
		url: aModalSymbol printString;
		attributeAt: 'data-toggle' put: 'modal';
		onClick: (
			(html jQuery id: titleId) load
				html: [ :ajaxHtml |
					self editField: aSelector.
					ajaxHtml text: title
				]
		);
		onClick: (
			(html jQuery id: inputId) value: aBlock value
		);
		onClick: (
			(html jQuery id: aModalSymbol)
				toggle
		);
		with: [
			html span: [
				html tbsGlyphIcon perform: anIconSelector
			]
		].
	html space
]

{ #category : #accessing }
FamilyTreeView >> selectedView [
	^ selectedView
]

{ #category : #accessing }
FamilyTreeView >> selectedView: aView [
	selectedView := aView
]
