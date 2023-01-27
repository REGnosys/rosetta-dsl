package com.regnosys.rosetta.formatting2

import com.google.inject.Inject
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import org.eclipse.xtext.testing.formatter.FormatterTestHelper
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaFormattingTest {
	@Inject
	extension FormatterTestHelper

	def ->(CharSequence unformated, CharSequence expectation) {
		assertFormatted[
			it.expectation = expectation
			it.toBeFormatted = unformated
			
			// extra check to make sure we didn't miss any hidden region in our formatter:
			it.allowUnformattedWhitespace = false 
			
			// see issue https://github.com/eclipse/xtext-core/issues/2058
			it.request.allowIdentityEdits = true
		
			// see issue https://github.com/eclipse/xtext-core/issues/164
			// and issue https://github.com/eclipse/xtext-core/issues/2060
			it.useSerializer = false
		]
	}
	
	@Test
	def void testBuiltinFeaturesAreGrouped() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			basicType string
			
			basicType int
			
			library function DateRanges() date
			
			library function Min(x number, y number) number
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			basicType string
			basicType int
			
			library function DateRanges() date
			library function Min(x number, y number) number
		'''
	}
	
	@Test
	def void testRedundantWhitespaceInEmptyRosettaFileIsRemoved() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
				
			
				
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
		'''
	}

	@Test
	def void simpleClassWithOneFieldIsFormatted() {
		'''
			namespace "com.regnosys.rosetta.model"
				version "test"
						type Test: <"Some definition"> field1 string (1..1) <"Field 1"> field2 string (1..1) <"Field 2">
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			type Test: <"Some definition">
			
				field1 string (1..1) <"Field 1">
				field2 string (1..1) <"Field 2">
		'''
	}

	@Test
	def void stereotypeIsSurroundedWithSingleSpace() {
		'''
			namespace "com.regnosys.rosetta.model" version "test" type CalculationPeriod: <"xxx xxx.">
				 [synonym FpML value "CalculationPeriod"]
			
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			type CalculationPeriod: <"xxx xxx.">
				[synonym FpML value "CalculationPeriod"]
		'''
	}

	@Test
	def void synonymIsOnSingleIndentedLine() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			type CalculationPeriod : <"xxx xxx."> [synonym FpML value "CalculationPeriod"]
					// sinleline comment
								field1 string (1..1) <"Some Field">[synonym FpML value "CalculationPeriod"]
			
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			type CalculationPeriod: <"xxx xxx.">
				[synonym FpML value "CalculationPeriod"]
			
				// sinleline comment
				field1 string (1..1) <"Some Field">
					[synonym FpML value "CalculationPeriod"]
		'''
	}

	@Test
	def void conditionOnType() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			type CalculationPeriod : <"xxx xxx.">  [  metadata   scheme  ] [synonym FpML value "CalculationPeriod"]
								// sinleline comment
						field3 string (1..1) <"Some Field">  [  metadata   scheme  ]
						// sinleline comment
						[synonym FpML value "CalculationPeriod"] 					field1 string (1..1) <"Some Field">[synonym FpML value "CalculationPeriod"] condition: one-of condition Foo: field1
			condition Foo12: 	optional 		choice field1 , field3
			// sinleline comment
						condition Foo2:
			optional
			choice field1 , field3  condition Foo4:
			required
			choice field1 , field3
				condition:
				one-of
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			type CalculationPeriod: <"xxx xxx.">
				[metadata scheme]
				[synonym FpML value "CalculationPeriod"]
			
				// sinleline comment
				field3 string (1..1) <"Some Field">
					[metadata scheme]
					// sinleline comment
					[synonym FpML value "CalculationPeriod"]
				field1 string (1..1) <"Some Field">
					[synonym FpML value "CalculationPeriod"]
			
				condition:
					one-of
			
				condition Foo:
					field1
			
				condition Foo12:
					optional choice field1, field3
			
			// sinleline comment
				condition Foo2:
					optional choice field1, field3
			
				condition Foo4:
					required choice field1, field3
			
				condition:
					one-of
		'''
	}

	@Test
	def void conditionOnFunc() {
		'''
			namespace "test"
			version "test"
			type Type: foo string (1..1) func Execute2:[ metadata  scheme ] inputs:		product string (1..1) <"">[synonym FpML value "CalculationPeriod"] 		quantity string (1..1) 	output:
					execution Type (1..1) <""> condition Foo: product set execution -> foo:
					"sdf"set execution:
					execution
			set execution:
			execution
			post-condition:
			execution -> foo is absent
		''' -> '''
			namespace "test"
			version "test"

			type Type:
			
				foo string (1..1)

			func Execute2:
				[metadata scheme]
				inputs:
					product string (1..1) <"">
						[synonym FpML value "CalculationPeriod"]
					quantity string (1..1)
				output:
					execution Type (1..1) <"">
				condition Foo:
					product
				set execution -> foo: "sdf"
				set execution: execution
				set execution: execution
				post-condition:
					execution -> foo is absent
		'''
	}

	@Test
	def void formatDatesReferenceEnum() {
		'''
			namespace "com.regnosys.rosetta.model" version "test" enum DatesReferenceEnum: <"The enumerated values to specify the set of dates that can be referenced through FpML href constructs of type ...periodDatesReference.">
				tradeDate
				effectiveDate firstRegularPeriodStartDate lastRegularPeriodEndDate cashSettlementPaymentDate <"">
				calculationPeriodDates <"FpML business validation rule ird-59 specifies that if resetDates exists in resetDates/calculationPeriodDatesReference, the @href attribute is equal to the @id attribute of calculationPeriodDates in the same swapStream.">
				paymentDates resetDates fixingDates valuationDates
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			enum DatesReferenceEnum: <"The enumerated values to specify the set of dates that can be referenced through FpML href constructs of type ...periodDatesReference.">
				tradeDate
				effectiveDate
				firstRegularPeriodStartDate
				lastRegularPeriodEndDate
				cashSettlementPaymentDate <"">
				calculationPeriodDates <"FpML business validation rule ird-59 specifies that if resetDates exists in resetDates/calculationPeriodDatesReference, the @href attribute is equal to the @id attribute of calculationPeriodDates in the same swapStream.">
				paymentDates
				resetDates
				fixingDates
				valuationDates
		'''
	}

	@Test
	def void formatDayOfWeekEnum() {
		'''namespace "com.regnosys.rosetta.model" version "test" enum DayOfWeekEnum: <"A day of the seven-day week."> [synonym FpML value "DayOfWeekEnum"] MON <"Monday">[synonym FpML value "MON"] TUE <"Tuesday">[synonym FpML value "TUE"] WED <"Wednesday">[synonym FpML value "WED"]THU <"Thursday">[synonym FpML value "THU"]FRI <"Friday">[synonym FpML value "FRI"]SAT <"Saturday">[synonym FpML value "SAT"]SUN <"Sunday">[synonym FpML value "SUN"]
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"

			enum DayOfWeekEnum: <"A day of the seven-day week.">
				[synonym FpML value "DayOfWeekEnum"]
				MON <"Monday">
					[synonym FpML value "MON"]
				TUE <"Tuesday">
					[synonym FpML value "TUE"]
				WED <"Wednesday">
					[synonym FpML value "WED"]
				THU <"Thursday">
					[synonym FpML value "THU"]
				FRI <"Friday">
					[synonym FpML value "FRI"]
				SAT <"Saturday">
					[synonym FpML value "SAT"]
				SUN <"Sunday">
					[synonym FpML value "SUN"]
			'''
	}

	@Test
	def void formatSpreadScheduleTypeEnum() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			enum SpreadScheduleTypeEnum: <"The enumerated values to specify a long or short spread value."> 	[synonym FpML value "spreadScheduleTypeScheme"]
				Long <"Represents a Long Spread Schedule. Spread schedules defined as 'Long' will be applied to Long Positions.">
			[synonym FpML value "Long"] Short <"Represents a Short Spread Schedule. Spread schedules defined as 'Short' will be applied to Short Positions.">
					[synonym FpML value "Short"]
		'''->'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			enum SpreadScheduleTypeEnum: <"The enumerated values to specify a long or short spread value.">
				[synonym FpML value "spreadScheduleTypeScheme"]
				Long <"Represents a Long Spread Schedule. Spread schedules defined as 'Long' will be applied to Long Positions.">
					[synonym FpML value "Long"]
				Short <"Represents a Short Spread Schedule. Spread schedules defined as 'Short' will be applied to Short Positions.">
					[synonym FpML value "Short"]
			'''
	}

	@Test
	def void formatExternalSynomym() {
		'''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			synonym source FpML_5_10
			
			synonym source MySynonymExtention extends FpML_5_10 {
				
				
				Contract:
				+ account	[value "my_account"]
				[value "my_account_2"]
				
				+ party [value "my_party"]
				
				
				Event:
					+ account
					[value "event_account"]
					
					
					
			}
		''' -> '''
			namespace "com.regnosys.rosetta.model"
			version "test"
			
			synonym source FpML_5_10
			
			synonym source MySynonymExtention extends FpML_5_10
			{
				Contract:
					+ account
						[value "my_account"]
						[value "my_account_2"]
					+ party
						[value "my_party"]
			
				Event:
					+ account
						[value "event_account"]
			}
		'''
	}

	@Test
	def void formatAttributeSynomym() {
		'''
			namespace "test"
			version "test"
			synonym source SynSource

			type AllocationOutcome:
				allocatedTrade AllocationOutcome (1..*)
											[synonym SynSource value "originalTrade"]
				originalTrade string (1..1)<"">
					[synonym SynSource value "allocatedTrade"]

				condition AllocationOutcome_executionClosed: <"The allocation outcome must result in execution state of 'Allocated' for an execution.">
					if AllocationOutcome -> allocatedTrade  exists
					then allocatedTrade -> allocatedTrade -> allocatedTrade = allocatedTrade
				condition AllocationOutcome_contractClosed: <"The allocation outcome must result in a contract state of 'Allocated' for a contract.">
					if AllocationOutcome -> allocatedTrade  exists
					then allocatedTrade -> allocatedTrade -> allocatedTrade = allocatedTrade
				condition AllocationOutcome_contractClosed:
					one-of
		''' -> '''
			namespace "test"
			version "test"
			
			synonym source SynSource

			type AllocationOutcome:
			
				allocatedTrade AllocationOutcome (1..*)
					[synonym SynSource value "originalTrade"]
				originalTrade string (1..1) <"">
					[synonym SynSource value "allocatedTrade"]
			
				condition AllocationOutcome_executionClosed: <"The allocation outcome must result in execution state of 'Allocated' for an execution.">
					if AllocationOutcome -> allocatedTrade exists
					then allocatedTrade -> allocatedTrade -> allocatedTrade = allocatedTrade
			
				condition AllocationOutcome_contractClosed: <"The allocation outcome must result in a contract state of 'Allocated' for a contract.">
					if AllocationOutcome -> allocatedTrade exists
					then allocatedTrade -> allocatedTrade -> allocatedTrade = allocatedTrade
			
				condition AllocationOutcome_contractClosed:
					one-of
		'''
	}
	
	@Test
	def void formatIndentationTest() {
		assertFormatted[
			preferences[
				put(FormatterPreferenceKeys.maxLineWidth, 20);
			]
			
			it.expectation = '''
				namespace "test"

				type AllocationOutcome:
				
					condition C1:
						if True
						then True
							= True
				
					condition C2:
						True
			'''
			it.toBeFormatted = '''
				namespace "test"

				type AllocationOutcome:
					condition C1:
						if True
						then True = True
					condition C2:
						True
			'''
		]
	}

	@Test
	def void formatListLiteral() {
		'''
			namespace "test"
						version "test"
			type Type:
							other Type (0..*)
			func Foo:
				inputs: in1 Type (1..1)
				output: out Type (1..1)
				add out -> other: [   
				in1
				,in1
				,in1,
				in1
				]
		''' -> '''
			namespace "test"
			version "test"
			
			type Type:
			
				other Type (0..*)
			
			func Foo:
				inputs:
					in1 Type (1..1)
				output:
					out Type (1..1)
				add out -> other: [in1, in1, in1, in1]
		'''
	}
}
