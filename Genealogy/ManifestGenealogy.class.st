"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGenealogy,
	#superclass : #PackageManifest,
	#category : #'Genealogy-Manifest'
}

{ #category : #'code-critics' }
ManifestGenealogy class >> ruleRBCollectionProtocolRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#Person)) #'2019-10-01T17:57:55.712267+01:00') )
]

{ #category : #'code-critics' }
ManifestGenealogy class >> ruleRBLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'Person class' #fromArray: #true)) #'2019-09-30T20:43:24.522062+01:00') )
]
