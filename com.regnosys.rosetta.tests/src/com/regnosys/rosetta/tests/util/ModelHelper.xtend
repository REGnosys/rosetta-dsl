package com.regnosys.rosetta.tests.util

import com.google.inject.Inject
import com.regnosys.rosetta.generator.java.RosettaJavaPackages.RootPackage
import com.regnosys.rosetta.rosetta.RosettaModel
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper

class ModelHelper {

	@Inject extension ParseHelper<RosettaModel>
	@Inject extension ValidationTestHelper 

	public static val commonEnums = '''
		«getVersionInfo»
		
		basicType string
		basicType int
		basicType number
		basicType boolean
		basicType time
		basicType dateTime
		basicType date
		basicType zonedDateTime
		
		library function DateRanges() date
		library function Min(x number, y number) number
		library function Max(x number, y number) number
		library function Adjust() date
		library function Within() boolean
		
		qualifiedType productType
		qualifiedType eventType
		
		calculationType calculation
		
		body Authority ESMA
		body Authority CFTC
		
		organisation ISDA
		organisation SIFMA
		organisation FIX_TradingCommunity
		
		corpus Regulation MiFIR
		corpus Regulation EMIR
		
		corpus CommissionDelegatedRegulation RTS_22
		
		segment article
		segment whereas
		segment annex
		segment section
		segment field
		
		stereotype entityReferenceData
		stereotype productReferenceData
		stereotype commondReferenceData
		stereotype preExecutionActivity
		stereotype executionActivity
		stereotype postExecutionActivity
		stereotype contractualProduct
		stereotype regulatoryEligibility
		stereotype regulatoryReporting
		
		synonym source FIX
		synonym source FpML
		synonym source DTCC
		synonym source ISO
		synonym source ISO_20022
		synonym source Bank_A
		synonym source Venue_B
	'''

	private def static getVersionInfo() {
		'''
			namespace "com.rosetta.test.model"
			version "test"
		'''
	}
	
	val rootpack = new RootPackage("com.rosetta.test.model")

	final def RootPackage rootPackage() {
		return rootpack
	}

	def parseRosetta(CharSequence model) {
		var m = model;
		if (model.subSequence(0,9)!="namespace") {
			m = versionInfo + "\n" + m
		}
		val resourceSet = parse(commonEnums).eResource.resourceSet
		resourceSet.getResource(URI.createURI('classpath:/model/annotations.rosetta'), true)
		val parsed = m.parse(resourceSet)
		return parsed;
	}

	def parseRosettaWithNoErrors(CharSequence model) {
		val parsed = parseRosetta(model)
		parsed.assertNoErrors
		return parsed;
	}

	def combineAndParseRosetta(CharSequence... models) {
		var m = versionInfo.toString
		for (model : models) {
			m += "\n" + model
		}
		val resourceSet = parse(commonEnums).eResource.resourceSet
		val parsed = m.parse(resourceSet)
		parsed.assertNoErrors
		return parsed;
	}
}
