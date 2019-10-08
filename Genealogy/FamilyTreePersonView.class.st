"
I represent a full view of a person.
"
Class {
	#name : #FamilyTreePersonView,
	#superclass : #WAComponent,
	#instVars : [
		'selectedView',
		'parentView',
		'person',
		'editField',
		'editValue'
	],
	#category : #Genealogy
}

{ #category : #defaults }
FamilyTreePersonView class >> defaultGenders [
	^ #('male' 'female' 'unknown' 'non binary' 'other')
]

{ #category : #'instance creation' }
FamilyTreePersonView class >> on: aPerson for: aView selectedView: aSelectedView [
	^ self new person: aPerson; parentView: aView; selectedView: aSelectedView
]

{ #category : #defaults }
FamilyTreePersonView class >> valueForGender: aGender [
	^ self defaultGenders indexOf: aGender
]

{ #category : #accessing }
FamilyTreePersonView >> editField [
	^ editField
]

{ #category : #accessing }
FamilyTreePersonView >> editField: aPersonField [
	editField := aPersonField
]

{ #category : #accessing }
FamilyTreePersonView >> editValue [
	^ editValue
]

{ #category : #accessing }
FamilyTreePersonView >> editValue: aString [
	editValue := aString
]

{ #category : #accessing }
FamilyTreePersonView >> parentView [
	^ parentView
]

{ #category : #accessing }
FamilyTreePersonView >> parentView: aView [
	parentView := aView
]

{ #category : #accessing }
FamilyTreePersonView >> person [
	^ person
]

{ #category : #accessing }
FamilyTreePersonView >> person: aPerson [
	person := aPerson
]

{ #category : #rendering }
FamilyTreePersonView >> renderCompactPerson: aPerson on: html [
	html tbsRow
		class: 'selectable';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parentView selectedPerson: aPerson.
					self parentView renderPersonOn: ajaxHtml
				]
		);
		with: [
			html tbsColumn
				mediumOffset: 1;
				with: [
					html text: aPerson fullName.
					self renderDatesForPerson: aPerson on: html
				]
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderContentOn: html [
	self person
		ifNil: [ html text: 'no entry selected' ]
		ifNotNil: [ self renderPersonOn: html ]
]

{ #category : #rendering }
FamilyTreePersonView >> renderDatesForPerson: aPerson on: html [
	html text: ' [b: '.
	html text: aPerson birthString.
	html text: ', d: '.
	html text: aPerson deathString.
	html text: ']'
]

{ #category : #rendering }
FamilyTreePersonView >> renderGenderEditorOn: html [
	html tbsModal id: #genderEditorModal; with: [  
		html tbsModalDialog: [
			html tbsModalContent: [ 
				html tbsModalHeader: [ 
					html tbsModalCloseIcon.
					html tbsModalTitle
						id: #genderEditorTitle;
						level: 4;
						with: 'Editor'				
				 ].
				html tbsModalBody: [
					html div
						id: #genderEditorForm;
						with: [
							self renderGenderFormOn: html
						]
				].
				html tbsModalFooter: [ 
					html tbsButton
						attributeAt: 'data-dismiss' put: 'modal';
						with: 'Close'.
					html tbsButton
						bePrimary;
						attributeAt: 'data-dismiss' put: 'modal';
						onClick: (
							((html jQuery id: #main) load)
								html: [ :ajaxHtml |
									self updatePerson.
									self parentView renderPersonOn: ajaxHtml
								]
						);
						onClick: (
							((html jQuery id: self selectedView viewId) load)
								html: [ :ajaxHtml |
									self selectedView renderPersonOn: ajaxHtml
								]
						);
						with: 'Save' 	
				 ]
			]
		]	
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderGenderFormOn: html [
	html form
		with: [
			html select
				id: #genderEditorText;
				list: self class defaultGenders;
				onChange: (
					((html jQuery id: #genderEditorForm) load)
						serializeForm;
						html: [ :ajaxHtml | self renderGenderFormOn: ajaxHtml ]
				);
				selected: self editValue;
				callback: [ :newValue | self editValue: newValue ]
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderGenderOn: html [
	html anchor
		url: '#genderEditorModal';
		attributeAt: 'data-toggle' put: 'modal';
		onClick: (
			(html jQuery id: #genderEditorTitle) load
				html: [ :ajaxHtml |
					self editField: #gender:.
					self editValue: self person gender.
					ajaxHtml text: 'Edit gender'
				]
		);
		onClick: (
			(html jQuery id: #genderEditorText) value: (self class valueForGender: self person gender)
		);
		onClick: (
			(html jQuery id: #genderEditorModal)
				toggle
		);
		with: [
			html text: 'Gender: '.
			html text: self person gender
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderGrandParentsOn: html [
	html heading level: 3; with: 'Grandparents'.
	self person grandParents do: [ :grandParent |
		self renderCompactPerson: grandParent on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderMainInfoOn: html [
	self renderPersonForenamesOn: html. html break.
	self renderPersonSurnameOn: html. html break.
	self renderPersonNicknameOn: html. html break.
	self renderGenderOn: html.
	self renderPersonBirthOn: html.
	self renderPersonDeathOn: html
]

{ #category : #rendering }
FamilyTreePersonView >> renderParentsOn: html [
	html heading level: 3; with: 'Parents'.
	self person parents do: [ :parent |
		self renderCompactPerson: parent on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPartner: aPartner on: html [
	html heading
		level: 4;
		class: 'selectable';
		onClick: (
			((html jQuery id: #main) load)
				html: [ :ajaxHtml |
					self parentView selectedPerson: aPartner.
					self parentView renderPersonOn: ajaxHtml
				]
		);
		with: [
			html text: aPartner fullName.
			self renderDatesForPerson: aPartner on: html
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonBirthOn: html [
	html heading
		level: 5;
		with: [
			html text: 'Born: '.
			html text: self person birthWithLocationString
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonDeathOn: html [
	html heading
		level: 5;
		with: [
			html text: 'Died: '.
			html text: self person deathWithLocationString
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonForenamesOn: html [
	html anchor
		url: '#textEditorModal';
		attributeAt: 'data-toggle' put: 'modal';
		onClick: (
			(html jQuery id: #textEditorTitle) load
				html: [ :ajaxHtml |
					self editField: #forenames:.
					ajaxHtml text: 'Edit forenames'
				]
		);
		onClick: (
			(html jQuery id: #textEditorText) value: self person forenames
		);
		onClick: (
			(html jQuery id: #textEditorModal)
				toggle
		);
		with: [
			html text: 'Forenames: '.
			html text: self person forenames
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonNicknameOn: html [
	html anchor
		url: '#textEditorModal';
		attributeAt: 'data-toggle' put: 'modal';
		onClick: (
			(html jQuery id: #textEditorTitle) load
				html: [ :ajaxHtml |
					self editField: #nickname:.
					ajaxHtml text: 'Edit nickname'
				]
		);
		onClick: (
			(html jQuery id: #textEditorText) value: self person nickname
		);
		onClick: (
			(html jQuery id: #textEditorModal)
				toggle
		);
		with: [
			html text: 'Nickname: '.
			html text: self person nickname
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonOn: html [
	self renderTextEditorOn: html.
	self renderGenderEditorOn: html.
	html heading level: 3; with: self person fullName.
	self renderMainInfoOn: html.
	self renderGrandParentsOn: html.
	self renderParentsOn: html.
	self renderSiblingsOn: html.
	self renderRelationshipsOn: html
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonSurnameOn: html [
	html anchor
		url: '#textEditorModal';
		attributeAt: 'data-toggle' put: 'modal';
		onClick: (
			(html jQuery id: #textEditorTitle) load
				html: [ :ajaxHtml |
					self editField: #surname:.
					ajaxHtml text: 'Edit surname'
				]
		);
		onClick: (
			(html jQuery id: #textEditorText) value: self person surname
		);
		onClick: (
			(html jQuery id: #textEditorModal)
				toggle
		);
		with: [
			html text: 'Surname: '.
			html text: self person surname
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationship: aFamily on: html [
	aFamily partners do: [ :partner | self renderPartner: partner on: html ] without: self person.
	aFamily children ifEmpty: [ ^ self ].
	html heading level: 5; with: 'Children'.
	aFamily children do: [ :child |
		self renderCompactPerson: child on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationshipsOn: html [
	html heading level: 3; with: 'Relationships'.
	self person relationships do: [ :family |
		self renderRelationship: family on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderSiblingsOn: html [
	html heading level: 3; with: 'Siblings'.
	self person siblings do: [ :sibling |
		self renderCompactPerson: sibling on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderTextEditorOn: html [
	html tbsModal id: #textEditorModal; with: [  
		html tbsModalDialog: [
			html tbsModalContent: [ 
				html tbsModalHeader: [ 
					html tbsModalCloseIcon.
					html tbsModalTitle
						id: #textEditorTitle;
						level: 4;
						with: 'Editor'				
				 ].
				html tbsModalBody: [
					html form
						with: [
							html textInput
								id: #textEditorText;
								onChange: (
									(html jQuery this) load
										serializeForm
								);
								callback: [ :newText | self editValue: newText ]
						]
				].
				html tbsModalFooter: [ 
					html tbsButton
						attributeAt: 'data-dismiss' put: 'modal';
						with: 'Close'.
					html tbsButton
						bePrimary;
						attributeAt: 'data-dismiss' put: 'modal';
						onClick: (
							((html jQuery id: #main) load)
								html: [ :ajaxHtml |
									self updatePerson.
									self parentView renderPersonOn: ajaxHtml
								]
						);
						onClick: (
							((html jQuery id: self selectedView viewId) load)
								html: [ :ajaxHtml |
									self selectedView renderPersonOn: ajaxHtml
								]
						);
						with: 'Save' 	
				 ]
			]
		]	
	]
]

{ #category : #accessing }
FamilyTreePersonView >> selectedView [
	^ selectedView
]

{ #category : #accessing }
FamilyTreePersonView >> selectedView: aView [
	selectedView := aView
]

{ #category : #updating }
FamilyTreePersonView >> updatePerson [
	self editField ifNil: [ ^ self ].
	self person perform: self editField with: self editValue.
	self editField: nil.
	self editValue: nil
]
