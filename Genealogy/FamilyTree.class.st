"
I am a family tree application.
"
Class {
	#name : #FamilyTree,
	#superclass : #WAComponent,
	#classInstVars : [
		'credentials'
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
FamilyTree class >> getGoogleProfileFromToken: token [
	| url request |
	url := 'https://www.googleapis.com/oauth2/v1/userinfo'.
	request := ZnClient new url: url.
	request queryAt: 'access_token' put: token.
	^ WAJsonParser parse: request get
]

{ #category : #'class initialization' }
FamilyTree class >> initialize [
	"self initialize"
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

{ #category : #logout }
FamilyTree >> login [
	^ self redirect
]

{ #category : #logout }
FamilyTree >> logout [
	self session logout
]

{ #category : #login }
FamilyTree >> performLogin [
	| code tokenRequest tokenResponse accessToken refreshToken idToken user |
	code := self requestContext request queryFields at: 'code' ifAbsent: [ nil ].
	code ifNil: [ ^ self ].
	tokenRequest := self class tokenRequestForCode: code.
	tokenResponse := WAJsonParser parse: tokenRequest post.
	accessToken := (tokenResponse at: 'access_token' ifAbsent: [ nil ]).
	refreshToken := (tokenResponse at: 'refresh_token' ifAbsent: [ nil ]).
	idToken := (tokenResponse at: 'id_token' ifAbsent: [ nil ]).
	user := self class getGoogleProfileFromToken: accessToken.
	(user includesKey: 'error') ifTrue: [ ^ self ].
	self session accessToken: accessToken.
	self session refreshToken: refreshToken.
	self session idToken: idToken.
	self session login: user
]

{ #category : #login }
FamilyTree >> redirect [
	^ self requestContext responseGenerator
		redirectTo: self class defaultRedirectUrl;
		respond
]

{ #category : #rendering }
FamilyTree >> renderContentOn: html [
	self performLogin.
	html heading: 'Family Tree'.
	self session isLoggedIn
		ifTrue: [ self renderLoggedInViewOn: html ]
		ifFalse: [ self renderLoggedOutViewOn: html ]
]

{ #category : #rendering }
FamilyTree >> renderLoggedInViewOn: html [
	| image |
	html heading level: 3; with: 'Logged in'.
	image := self session user at: 'picture' ifAbsent: [ nil ].
	image ifNotNil: [
		html image url: image
	].
	html form: [
		html submitButton
			callback: [ self logout ];
			with: 'Logout'
	]
]

{ #category : #rendering }
FamilyTree >> renderLoggedOutViewOn: html [
	html form: [
		html submitButton
			callback: [ self login ];
			with: 'Login with Google'
	]
]

{ #category : #updating }
FamilyTree >> updateRoot: htmlRoot [
	htmlRoot title: 'Family Tree'
]
