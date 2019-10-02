"
I am a family tree application.
"
Class {
	#name : #FamilyTree,
	#superclass : #WAComponent,
	#category : #Genealogy
}

{ #category : #'class initialization' }
FamilyTree class >> initialize [
	"self initialize"
	(WAAdmin register: self asApplicationAt: 'family')
		preferenceAt: #sessionClass put: FamilyTreeSession;
		addLibrary: JQDeploymentLibrary;
		addLibrary: JQUiDeploymentLibrary;
		addLibrary: TBSDeploymentLibrary
]

{ #category : #rendering }
FamilyTree >> renderContentOn: html [
	html heading: 'Family Tree'
]

{ #category : #updating }
FamilyTree >> updateRoot: htmlRoot [
	htmlRoot title: 'Family Tree'
]
