"
I am a family tree application.
"
Class {
	#name : #FamilyTree,
	#superclass : #WAComponent,
	#instVars : [
		'selectedPerson',
		'selectedView'
	],
	#classInstVars : [
		'credentials',
		'validUsers'
	],
	#category : #Genealogy
}

{ #category : #defaults }
FamilyTree class >> clientId [
	^ self credentials at: 'web' at: 'client_id'
]

{ #category : #defaults }
FamilyTree class >> clientSecret [
	^ self credentials at: 'web' at: 'client_secret'
]

{ #category : #defaults }
FamilyTree class >> credentials [
	^ credentials ifNil: [ credentials := self defaultCredentials ]
]

{ #category : #defaults }
FamilyTree class >> defaultCredentials [
	| fileStream |
	fileStream := '/Users/bush/Downloads/credentials.json' asFileReference readStream.
	^ WAJsonParser parse: fileStream contents
]

{ #category : #defaults }
FamilyTree class >> defaultRedirectUrl [
	| url query |
	url := ZnUrl fromString: 'https://accounts.google.com/o/oauth2/v2/auth'.
	query := ZnMultiValueDictionary new.
	query at: 'scope' add: self defaultScopes.
	query at: 'redirect_uri' add: 'http://localhost:8080/family'.
	query at: 'response_type' add: 'code'.
	query at: 'client_id' add: self clientId.
	url query: query.
	^ url
]

{ #category : #defaults }
FamilyTree class >> defaultScopes [
	^ 'profile email openid'
]

{ #category : #defaults }
FamilyTree class >> defaultUsers [
	^ #('mark@bushnet.org')
]

{ #category : #defaults }
FamilyTree class >> getGoogleProfileFromToken: token [
	| url request |
	url := 'https://www.googleapis.com/oauth2/v1/userinfo'.
	request := ZnClient new url: url.
	request queryAt: 'access_token' put: token.
	^ WAJsonParser parse: request get
]

{ #category : #defaults }
FamilyTree class >> getUserForCode: code [
	| tokenRequest tokenResponse accessToken refreshToken idToken userDict user |
	tokenRequest := self tokenRequestForCode: code.
	tokenResponse := WAJsonParser parse: tokenRequest post.
	accessToken := (tokenResponse at: 'access_token' ifAbsent: [ nil ]).
	refreshToken := (tokenResponse at: 'refresh_token' ifAbsent: [ nil ]).
	idToken := (tokenResponse at: 'id_token' ifAbsent: [ nil ]).
	userDict := self getGoogleProfileFromToken: accessToken.
	(userDict includesKey: 'error') ifTrue: [ ^ nil ].
	user := FamilyTreeUser fromGoogleUserInfo: userDict.
	(self validUsers includes: user email)
		ifFalse: [ ^ nil ].
	user accessToken: accessToken; refreshToken: refreshToken; idToken: idToken.
	^ user
]

{ #category : #'class initialization' }
FamilyTree class >> initialize [
	"self initialize"
	validUsers := self defaultUsers.
	(WAAdmin register: self asApplicationAt: 'family')
		preferenceAt: #sessionClass put: FamilyTreeSession;
		addLibrary: JQDeploymentLibrary;
		addLibrary: JQUiDeploymentLibrary;
		addLibrary: TBSDeploymentLibrary
]

{ #category : #defaults }
FamilyTree class >> tokenRequestForCode: code [
	| request query |
	request := ZnClient new url: 'https://accounts.google.com/o/oauth2/token'.
	query := Dictionary new.
	query at: 'code' put: code.
	query at: 'client_id' put: self clientId.
	query at: 'client_secret' put: self clientSecret.
	query at: 'redirect_uri' put: 'http://localhost:8080/family'.
	query at: 'grant_type' put: 'authorization_code'.
	request formAddAll: query.
	^ request
]

{ #category : #accessing }
FamilyTree class >> validUsers [
	^ validUsers ifNil: [ validUsers := self defaultUsers ]
]

{ #category : #testing }
FamilyTree >> isLoggedIn [
	^ self session isLoggedIn
]

{ #category : #login }
FamilyTree >> login [
	^ self redirect
]

{ #category : #login }
FamilyTree >> login: aUser [
	self session login: aUser
]

{ #category : #accessing }
FamilyTree >> loginUser [
	^ self session user
]

{ #category : #logout }
FamilyTree >> logout [
	self session logout
]

{ #category : #login }
FamilyTree >> performLoginOn: html [
	| code user |
	code := self requestContext request queryFields at: 'code' ifAbsent: [ nil ].
	code ifNil: [ ^ self ].
	user := self class getUserForCode: code.
	user ifNotNil: [
		self login: user.
		"Redirect to preserve the session and remove Google login parameters."
		self requestContext responseGenerator redirectTo: html actionUrl; respond
	]
]

{ #category : #login }
FamilyTree >> redirect [
	| url |
	url := self class defaultRedirectUrl.
	^ self requestContext responseGenerator redirectTo: url; respond
]

{ #category : #rendering }
FamilyTree >> renderContentOn: html [
	self isLoggedIn ifFalse: [ self performLoginOn: html ].
	self renderNavbarOn: html.
	self isLoggedIn
		ifTrue: [ self renderLoggedInViewOn: html ]
		ifFalse: [ self renderLoggedOutViewOn: html ]
]

{ #category : #rendering }
FamilyTree >> renderLoggedInMainOn: html [
	html tbsColumn
		id: #main;
		class: 'main';
		mediumOffset: 3;
		mediumSize: 9;
		with: [
			self selectedPerson
				ifNil: [ html text: 'No entry selected' ]
				ifNotNil: [ self renderPersonOn: html ]
		]
]

{ #category : #rendering }
FamilyTree >> renderLoggedInNavbarOn: html [
	html form
		tbsPullLeft;
		with: [
			html tbsNavbarButton
				callback: [ self logout ];
				with: 'Logout'
		].
	html tbsNavbarText tbsPullRight with: [
		html text: 'Logged in as ' , self loginUser name.
		self loginUser picture
			ifNotNil: [ html image url: self loginUser picture ]
	]
]

{ #category : #rendering }
FamilyTree >> renderLoggedInSidebarOn: html [
	html tbsColumn
		class: 'sidebar';
		mediumSize: 3;
		with: [
			Person allPeople do: [ :person |
					html render: (FamilyTreeCompactPersonView on: person for: self)
			]
		]
]

{ #category : #rendering }
FamilyTree >> renderLoggedInViewOn: html [
	html div
		class: 'container-fluid';
		with: [
			html tbsRow
				with: [
					html div
						id: #sidebar;
						with: [
							self renderLoggedInSidebarOn: html.
						].
					self renderLoggedInMainOn: html
				]
		]
]

{ #category : #rendering }
FamilyTree >> renderLoggedOutNavbarOn: html [
	html form
		tbsPullLeft;
		with: [
			html tbsNavbarButton
				callback: [ self login ];
				with: 'Login with Google'
		]
]

{ #category : #rendering }
FamilyTree >> renderLoggedOutViewOn: html [
	html heading level: 3; with: 'You need to log in to use this app'
]

{ #category : #rendering }
FamilyTree >> renderNavbarOn: html [
	html tbsNavbar
		beDefault;
		class: 'navbar-fixed-top';
		with: [
			html tbsNavbarBrand
				url: html actionUrl;
				with: 'Bush Family Tree'.
			self isLoggedIn
				ifTrue: [ self renderLoggedInNavbarOn: html ]
				ifFalse: [ self renderLoggedOutNavbarOn: html ]
		]
]

{ #category : #rendering }
FamilyTree >> renderPersonOn: html [
	html render: (FamilyTreePersonView on: self selectedPerson for: self selectedView: self selectedView)
]

{ #category : #accessing }
FamilyTree >> selectedPerson [
	^ selectedPerson
]

{ #category : #accessing }
FamilyTree >> selectedPerson: aPerson [
	selectedPerson := aPerson
]

{ #category : #accessing }
FamilyTree >> selectedView [
	^ selectedView
]

{ #category : #accessing }
FamilyTree >> selectedView: aView [
	selectedView := aView
]

{ #category : #hooks }
FamilyTree >> style [
	^ '
body {
	height: 100%;
	padding-top: 71px;
}
.navbar img {
	height: 40px;
	margin-left: 10px;
	border-radius: 50%;
}
.sidebar {
	position: fixed;
	top: 71px;
	bottom:25px;
	left: 0;
	z-index: 1000;
	display: block;
	overflow-x: hidden;
	overflow-y: auto; /* Scrollable contents if viewport is shorter than content. */
	background-color: #f5f5f5;
	border-right: 1px solid #eee;
}
.person-compact {
	border-bottom: 1px solid #eee;
}
.selectable {
	cursor: pointer;
}
.person-name {
	font-size: 120%;
	font-weight: bold;
}
.main {
}
'
]

{ #category : #updating }
FamilyTree >> updateRoot: htmlRoot [
	super updateRoot: htmlRoot.
	htmlRoot title: 'Family Tree'
]
