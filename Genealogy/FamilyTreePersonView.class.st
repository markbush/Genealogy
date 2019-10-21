"
I represent a full view of a person.
"
Class {
	#name : #FamilyTreePersonView,
	#superclass : #FamilyTreeView,
	#instVars : [
		'person'
	],
	#category : #Genealogy
}

{ #category : #defaults }
FamilyTreePersonView class >> defaultGenders [
	^ #('unknown' 'male' 'female' 'non binary' 'other')
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
FamilyTreePersonView >> person [
	^ person
]

{ #category : #accessing }
FamilyTreePersonView >> person: aPerson [
	person := aPerson
]

{ #category : #rendering }
FamilyTreePersonView >> renderCompactPerson: aPerson on: html offset: anOffset [
	html tbsColumn
		mediumOffset: anOffset;
		with: (FamilyTreePersonCompactView on: aPerson for: self parentView)
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
	(aPerson isAlive and: [ aPerson age isNotNil ])
		ifTrue: [
			html text: ' (' , aPerson age truncated printString , ')'
		].
	html text: ', d: '.
	html text: aPerson deathString.
	(aPerson isDeceased and: [ aPerson age isNotNil ])
		ifTrue: [
			html text: ' (' , aPerson age truncated printString , ')'
		].
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
FamilyTreePersonView >> renderGrandParentsOn: html [
	html heading level: 3; with: 'Grandparents'.
	self person grandParents do: [ :grandParent |
		self renderCompactPerson: grandParent on: html offset: 1
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderMainInfoOn: html [
	html div
		class: 'person-info';
		with: [
			self renderPersonForenamesOn: html. html break.
			self renderPersonSurnameOn: html. html break.
			self renderPersonNicknameOn: html. html break.
			self renderPersonGenderOn: html. html break.
			self renderPersonBirthOn: html. html break.
			self renderPersonDeathOn: html. html break.
		]

]

{ #category : #rendering }
FamilyTreePersonView >> renderParentsOn: html [
	html heading level: 3; with: 'Parents'.
	self person parents do: [ :parent |
		self renderCompactPerson: parent on: html offset: 1
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
FamilyTreePersonView >> renderPersonBirthDateOn: html [
	self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit birth date' fieldSelector: #birthString: inputId: #textEditorText valueBlock: [ self person birthString ].
	html span class: 'person-label'; with: 'Born: '.
	html text: self person birthString
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonBirthLocationOn: html [
	html span
		with: [
			html text: ' ('.
			self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit birth location' fieldSelector: #birthLocation: inputId: #textEditorText valueBlock: [ self person birthLocation ].
			html span class: 'person-label'; with: 'Location: '.
			html text: self person birthLocation.
			html text: ')'
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonBirthOn: html [
	| age |
	self renderPersonBirthDateOn: html.
	self renderPersonBirthLocationOn: html.
	self person isDeceased ifTrue: [ ^ self ].
	age := self person age.
	age ifNotNil: [
		html text: ' (' , age printString , ' years old)'
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonDeathDateOn: html [
	self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit death date' fieldSelector: #deathString: inputId: #textEditorText valueBlock: [ self person deathString ].
	html span
		class: (self person isAlive ifTrue: [ 'person-label-subdued' ] ifFalse: [ 'person-label' ]);
		with: 'Died: '.
	html text: self person deathString
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonDeathLocationOn: html [
	html span
		with: [
			html text: ' ('.
			self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit death location' fieldSelector: #deathLocation: inputId: #textEditorText valueBlock: [ self person deathLocation ].
			html span
				class: (self person isAlive ifTrue: [ 'person-label-subdued' ] ifFalse: [ 'person-label' ]);
				with: 'Location: '.
			html text: self person deathLocation.
			html text: ')'
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonDeathOn: html [
	| age |
	self renderPersonDeathDateOn: html.
	self renderPersonDeathLocationOn: html.
	self person isAlive ifTrue: [ ^ self ].
	age := self person age.
	age ifNotNil: [
		html text: ' (at ' , age printString , ' years old)'
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonForenamesOn: html [
	self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit forenames' fieldSelector: #forenames: inputId: #textEditorText valueBlock: [ self person forenames ].
	html span class: 'person-label'; with: 'Forenames: '.
	html text: self person forenames
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonGenderOn: html [
	self renderTo: html linkForModal: #genderEditorModal titleId: #genderEditorTitle title: 'Edit gender' fieldSelector: #gender: inputId: #genderEditorText valueBlock: [ self class valueForGender: self person gender ].
	html span class: 'person-label'; with: 'Gender: '.
	html text: self person gender
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonNicknameOn: html [
	self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit nickname' fieldSelector: #nickname: inputId: #textEditorText valueBlock: [ self person nickname ].
	html span class: 'person-label'; with: 'Nickname: '.
	html text: self person nickname
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonNote: aNote on: html [
	html paragraph with: [
		html anchor
			url: '#';
			onClick: (
				((html jQuery id: #main) load)
					html: [ :ajaxHtml |
						self person removeNote: aNote.
						self parentView renderPersonOn: ajaxHtml
					]
				);
			with: [
				html span with: [
					html tbsGlyphIcon iconRemove
				]
			].
		html space.
		html text: aNote
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonNotesOn: html [
	html heading
		level: 4;
		with: [
			html text: 'Notes'.
			html space.
			self renderTo: html linkForModal: #textAreaEditorModal titleId: #textAreaEditorTitle title: 'Add note' fieldSelector: #addNote: inputId: #textAreaEditorText valueBlock: [ '' ] icon: #iconPlus
		].
	self person notes do: [ :note |
		self renderPersonNote: note on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonOn: html [
	self renderTextEditorOn: html.
	self renderTextAreaEditorOn: html.
	self renderGenderEditorOn: html.
	html heading level: 3; with: self person fullName.
	self renderMainInfoOn: html.
	self renderPersonNotesOn: html.
	self renderGrandParentsOn: html.
	self renderParentsOn: html.
	self renderSiblingsOn: html.
	self renderRelationshipsOn: html
]

{ #category : #rendering }
FamilyTreePersonView >> renderPersonSurnameOn: html [
	self renderTo: html linkForModal: #textEditorModal titleId: #textEditorTitle title: 'Edit surname' fieldSelector: #surname: inputId: #textEditorText valueBlock: [ self person surname ].
	html span class: 'person-label'; with: 'Surname: '.
	html text: self person surname.
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationship: aFamily on: html [
	aFamily partners do: [ :partner |
		self renderCompactPerson: partner on: html offset: 0
	] without: self person.
	aFamily events do: [ :e | self renderRelationshipEvent: e on: html ].
	aFamily children ifEmpty: [ ^ self ].
	html heading level: 5; with: 'Children'.
	aFamily children do: [ :child |
		self renderCompactPerson: child on: html offset: 1
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationshipEvent: anEvent on: html [
	^ html heading
		level: 4;
		with: [
			html text: anEvent type.
			html space.
			html text: anEvent dateAndLocationString
		]
]

{ #category : #rendering }
FamilyTreePersonView >> renderRelationshipsOn: html [
	html heading level: 3; with: 'Relationships'.
	self person relationships do: [ :family |
		html render: (FamilyTreeRelationshipView on: family for: self parentView).
		self renderRelationship: family on: html
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderSiblingsOn: html [
	html heading level: 3; with: 'Siblings'.
	self person siblings do: [ :sibling |
		self renderCompactPerson: sibling on: html offset: 1
	]
]

{ #category : #rendering }
FamilyTreePersonView >> renderTextAreaEditorOn: html [
	html tbsModal id: #textAreaEditorModal; with: [
		html tbsModalDialog: [
			html tbsModalContent: [
				html tbsModalHeader: [
					html tbsModalCloseIcon.
					html tbsModalTitle
						id: #textAreaEditorTitle;
						level: 4;
						with: 'Editor'
				 ].
				html tbsModalBody: [
					html form
						with: [
							html textArea
								id: #textAreaEditorText;
								columns: 90;
								rows: 10;
								onChange: (
									(html jQuery this) load
										serializeForm
								);
								callback: [ :newText | self editValue: newText ]
						]
				].
				html tbsModalFooter: [
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
								size: 87;
								onChange: (
									(html jQuery this) load
										serializeForm
								);
								callback: [ :newText | self editValue: newText ]
						]
				].
				html tbsModalFooter: [
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

{ #category : #updating }
FamilyTreePersonView >> updatePerson [
	(self editField isNil or: [ self editValue isNil ])
		ifTrue: [ ^ self ].
	self person perform: self editField with: self editValue.
	self editField: nil.
	self editValue: nil
]
