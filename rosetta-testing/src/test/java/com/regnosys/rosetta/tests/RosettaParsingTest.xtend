/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.tests

import com.regnosys.rosetta.tests.util.ModelHelper
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import com.regnosys.rosetta.rosetta.simple.Function

import static org.junit.jupiter.api.Assertions.*
import com.regnosys.rosetta.rosetta.expression.MapOperation
import com.regnosys.rosetta.rosetta.expression.ListLiteral
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.expression.RosettaExistsExpression
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference

import static com.regnosys.rosetta.rosetta.expression.ExpressionPackage.Literals.*
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.EcoreUtil2
import com.regnosys.rosetta.rosetta.expression.ThenOperation
import com.regnosys.rosetta.rosetta.expression.RosettaPatternLiteral
import javax.inject.Inject

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaParsingTest {

	@Inject extension ModelHelper modelHelper
	@Inject extension ValidationTestHelper
	
	@Test
	def void testOnlyExistsInsideFunctionalOperation() {
		'''
		type A:
			b B (1..1)
		type B:
			val boolean (0..1)
		
		func Foo:
			inputs: a A (1..1)
			output: result boolean (1..1)
			set result:
				a extract [
					if item -> b -> val only exists
					then True
				]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testLegacyBlueprintSyntax() {
		val model = '''
			reporting rule BarBarOne from Bar:
				[legacy-syntax]
				(
					filter when Bar->test = True then extract Bar->bar1 + Bar->bar2,
					filter when Bar->test = False then extract Bar->bar2
				)  as "1 BarOne"
			
			type Bar:
				test boolean (1..1)
				bar1 string (0..1)
				bar2 string (1..1)
		'''.parseRosetta
		model.assertNoIssues
	}
	
	@Test
	def void testMaxCanBeChainedWithThen() {
		'''		
		func Foo:
			output: result int (0..*)
			add result:
				[1, 2, 3]
					extract item + 1
					then max
		'''.parseRosettaWithNoIssues
	}
	
	@Test
	def void orderOfParsingDoesNotMatter() {
		val model1 = '''
		namespace test.one
		
		type A:
			n int (1..1)
		'''
		val model2 = '''
		namespace test.two
		
		import test.one.A
		
		type B:
			a A (1..1)
		'''
		#[model1, model2].parseRosettaWithNoIssues
		#[model2, model1].parseRosettaWithNoIssues
	}
	
	@Test
	@Disabled // see issue https://github.com/REGnosys/rosetta-dsl/issues/524
	def void testPatternLiterals() {
		val model = '''
           func Foo:
             output: result pattern (0..*)
             
             add result: /ABC/
             add result: /[a-z]*/
             add result: /\/\+/
	    '''.parseRosettaWithNoIssues
	    
	    model.elements.head as Function => [
	    	operations.map[(expression as RosettaPatternLiteral).value] => [
	    		get(0) => [
	    			assertEquals("ABC", pattern)
	    		]
	    		get(1) => [
	    			assertEquals("[a-z]*", pattern)
	    		]
	    		get(2) => [
	    			assertEquals("/\\+", pattern)
	    		]
	    	]
	    ]
	}
	
	@Test
	def void testTypeAliases() {
		'''
			typeAlias int(digits int, min int, max int): number(digits: digits, fractionalDigits: 0, min: min, max: max)
			typeAlias max4String: string(minLength: 1, maxLength: 4)
		'''.parseRosettaWithNoIssues
	}
	
	@Test
	def void testParametrizedBasicTypes() {
		'''
			basicType pattern
			basicType int(digits int, min int, max int)
			basicType number(digits int, fractionalDigits int, min number, max number)
			basicType string(minLength int, maxLength int, pattern pattern)
		'''.parseRosettaWithNoIssues
	}
	
	@Test
	def void testPrioritisationOfOperations1() {
		val model =
		'''
			type Foo:
				bar Bar (0..*)
			type Bar:
				a string (0..*)
			func F:
				inputs: a string (1..1)
				output: result Bar (0..*)
				set result -> a: a
			
			func Test:
				inputs:
					foo Foo (1..1)
				output: result string (0..*)
				
				set result:
					foo -> bar only-element -> a
						join ", "
						then extract F(item) only-element -> a
						then filter item <> "foo"
				
				set result:
					(((((((foo -> bar) only-element) -> a)
						join ", ")
						then (extract F(item) only-element -> a)))
						then (filter item <> "foo"))
		'''.parseRosettaWithNoErrors
		model.elements.last as Function => [
			val expr1 = operations.head.expression
			val expr2 = operations.last.expression
			assertTrue(EcoreUtil2.equals(expr1, expr2));
		]
	}
	
	@Test
	def void testPrioritisationOfOperations2() {
		val model =
		'''
			type Foo:
				bar Bar (0..*)
			type Bar:
				a string (0..*)
			func F:
				inputs: bar Bar (1..1)
				output: result boolean (1..1)
				set result: bar -> a any = "foo"
			
			func Test:
				inputs:
					foo Foo (1..1)
				output: result string (0..*)
				
				set result:
					foo
						extract if F(bar only-element) = True and bar only-element -> a first = "bar"
							then bar
					    then extract [ item -> a
					    	filter [<> "foo"]
					    	then only-element ]
					    then extract item + "bar"
				
				set result:
					((foo
						extract (if ((F(bar only-element) = True) and (((bar only-element) -> a) first = "bar"))
							then bar))
					    then (extract [(((item -> a)
					    	filter [<> "foo"])
					    	then only-element)]))
					    then (extract (item + "bar"))
		'''.parseRosettaWithNoErrors
		model.elements.last as Function => [
			val expr1 = operations.head.expression
			val expr2 = operations.last.expression
			assertTrue(EcoreUtil2.equals(expr1, expr2));
		]
	}
	
	def void externalRuleReferenceParseTest() {
		'''
			type Foo:
				foo string (0..1)
			
			reporting rule RA:
				return "A"
			
			reporting rule RB:
				return "B"
			
			rule source TestA {
				Foo:
				+ foo
					[ruleReference RA]
			}
			
			rule source TestB extends TestA {
				Foo:
				- foo
				+ foo
					[ruleReference RB]
			}
		'''.parseRosettaWithNoIssues
	}
	
	@Test
	def void ambiguousReferenceAllowed() {
		val model =
		'''
			type Foo:
				a int (1..1)
			
			func F:
				inputs:
					foo Foo (1..1)
					a int (1..1)
				output: result int (1..1)
				set result:
					foo extract a
		'''.parseRosettaWithNoIssues
		
		model.elements.last as Function => [
			val aInput = inputs.last
	    	operations.head => [
	    		expression as MapOperation => [
	    			function => [
	    				assertTrue(body instanceof RosettaSymbolReference)
	    				body as RosettaSymbolReference => [
	    					assertEquals(aInput, symbol)
	    				]
	    			]
	    		]
	    	]
	    ]
	}
	
	@Test
	def void nameParsingDoesNotConflictWithScientificNotation() {
		'''           
           type E2:
             e2 int (1..1)
	    '''.parseRosettaWithNoIssues
	}
	
	@Test
	def void scientificNotationIsNotTooLoose() {
		val model = '''
           func Foo:
             output: result number (0..*)
             
             add result: .4a3
	    '''.parseRosetta
	    
	    model.assertError(ROSETTA_EXPRESSION, Diagnostic.SYNTAX_DIAGNOSTIC, "Character a is neither a decimal digit number, decimal point, nor \"e\" notation exponential mark.")
	}
	
	@Test
	def void canParseScientificNotation() {
		'''
           func Foo:
             output: result number (0..*)
             
             add result: .4e3
             add result: -5.E-2
             add result: 3.3e+42
             add result: 0.e0
	    '''.parseRosettaWithNoIssues
	}
	
	@Test
	def void testImplicitInput() {
	    val model = '''
           type Foo:
               a int (0..1)
               b string (0..1)
               
               condition C:
                   [deprecated] // the parser should parse this as an annotation, not a list
                   extract it -> a
                   then exists
           
           func F:
               inputs:
                   a int (1..1)
               output:
                   result boolean (1..1)
               set result:
                   a extract
                       if F
                       then False
                       else True and F
	    '''.parseRosetta

	    model.elements.head as Data => [
	    	conditions.head => [
	    		assertEquals(1, annotations.size)
	    		assertTrue(expression instanceof ThenOperation)
	    		expression as ThenOperation => [
	    			function => [
	    				assertTrue(body instanceof RosettaExistsExpression)
	    			]
	    		]
	    	]
	    ]
	    
	    model.assertNoIssues
	}
	
	@Test
	def void testExplicitArguments() {
	    val model = '''
           func F:
               inputs:
                   a int (1..1)
               output:
                   result boolean (1..1)
               set result:
                   F(a)
	    '''.parseRosetta

	    model.elements.head as Function => [
	    	operations.head.expression as RosettaSymbolReference => [
	    		assertTrue(explicitArguments)
	    		assertFalse(needsGeneratedInput)
	    	]
	    ]
	}
	
	@Test
	def void testMultiExtract() {
	    val model = '''
           func Test:
               output:
                   result boolean (0..*)
               add result:
                   [True, False]
                       extract [item = False]
                       extract [item = True]
	    '''.parseRosetta
	    
	    model.elements.last as Function => [
	    	operations.head => [
	    		assertTrue(expression instanceof MapOperation)
	    		expression as MapOperation => [
	    			assertTrue(argument instanceof MapOperation)
	    			argument as MapOperation => [
	    				assertTrue(argument instanceof ListLiteral)
	    			]
	    		]
	    	]
	    ]
	}
	
	@Test
	def void testExtractIsASynonymForMap() {
	    val model = '''
           func Test:
               output:
                   result boolean (0..*)
               add result:
                   [True, False] extract [item = False]
	    '''.parseRosetta
	    
	    model.elements.last as Function => [
	    	assertTrue(operations.last.expression instanceof MapOperation)
	    ]
	}
	
	@Test
	def void testOnlyElementInsidePath() {
	    '''
	           type A:
	               b B (0..*)
	           type B:
	               c C (1..1)
	           type C:
	           
	           func Test:
	               inputs:
	                   a A (1..1)
	               output:
	                   c C (1..1)
	               set c:
	                   a -> b only-element -> c
	    '''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testClass() {
	'''
			synonym source FpML
			synonym source FIX
			
			type PartyIdentifier: <"The set of [partyId, PartyIdSource] associated with a party.">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testClassWithEnumReference() {
	'''
			synonym source FpML
			synonym source FIX
			
			type PartyIdentifier: <"Bla">
				partyId string (1..1) <"Bla">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
				partyIdSource PartyIdSourceEnum (1..1)
					[synonym FIX value "PartyIDSource" tag 447]
					[synonym FpML value "PartyIdScheme"]
			
			enum PartyIdSourceEnum:
				LEI <"The Legal Entity Identifier">
				BIC <"The Bank Identifier Code">
				MIC
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testStandards() {
	'''
			synonym source FIX
			synonym source FpML
			synonym source ISO_20022
			
			type BasicTypes: <"">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
					[synonym ISO_20022 value "partyId"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymRefs() {
	'''
			synonym source FIX
			type BasicTypes: <"">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FIX value "PartyID" componentID 448]
					[synonym FIX value "PartyID.value"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testBasicTypes() {
	'''
			type Standards: <"">
				value1 int (0..1) <"">
				value3 number (0..1) <"">
				value5 boolean (0..1) <"">
				value6 date (0..1) <"">
				value9 string (0..1) <"">
				value10 zonedDateTime (0..1) <"">
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testEnumRegReferences() {
	'''
			enum PartyIdSourceEnum: <"The enumeration values associated with party identifier sources.">
				LEI <"The ISO 17442:2012 Legal Entity Identifier.">
				BIC <"The Bank Identifier Code.">
				MIC <"The ISO 10383 Market Identifier Code, applicable to certain types of execution venues, such as exchanges.">
				NaturalPersonIdentifier <"The natural person identifier.  When constructed according.">
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testMultipleSynonyms() {
	'''
			synonym source FpML
			synonym source FIX

			type PartyIdentifier: <"The set of [partyId, PartyIdSource] associated with a party.">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
				partyIdSource PartyIdSourceEnum (1..1) <"The reference source for the partyId, e.g. LEI, BIC.">
					[synonym FIX value "PartyIDSource" tag 447]
					[synonym FpML value "PartyIdScheme"]
			enum PartyIdSourceEnum: <"The enumeration values associated with party identifier sources.">
				LEI <"The Legal Entity Identifier">
				BIC <"The Bank Identifier Code">
				MIC <"The ISO 10383 Market Identifier Code, applicable to certain types of execution venues, such as exchanges.">
		'''.parseRosettaWithNoErrors
	}

	@Test
	def void testEnumeration() {
	'''
			synonym source FpML
			synonym source FIX
			
			enum QuoteRejectReasonEnum: <"The enumeration values to qualify the reason as to why a quote has been rejected.">
				UnknownSymbol
					[synonym FIX value "1" definition "foo"]
				ExchangeClosed
					[synonym FpML value "exchangeClosed" definition "foo" pattern "" ""]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testMultipleOrNoAttributeSynonym() {
	'''
			synonym source FIX
			synonym source FpML
			type TradeIdentifier: <"The trade identifier, along with the party that assigned it.">
				[synonym FpML value "partyTradeIdentifier"]
				IdentifyingParty string (1..1) <"The party that assigns the trade identifier">
				tradeId string (1..1) <"In FIX, the unique ID assigned to the trade entity once it is received or matched by the exchange or central counterparty.">
					[synonym FIX value "TradeID" tag 1003]
					[synonym FIX value "SecondaryTradeID" tag 1040]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testDataRuleWithChoice() {
	'''
			type Party:
				foo boolean (1..1)
				bar BarEnum (0..*)
				foobar string (0..1)
				condition Foo_Bar:
					if foo
					then
						if bar = BarEnum -> abc
							then foobar exists
						else foobar is absent
			enum BarEnum:
				abc
				bde
				cer
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testAttributeWithReferenceAnchorAndScheme() {
	'''
			synonym source FpML
			type Foo:
				foo string (1..1)
					[metadata reference]
					[metadata scheme]
					[synonym FpML value "foo" meta "href", "id", "fooScheme"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testChoiceRule() {
	'''
			type Foo:
				foo Color (1..*)
				bar string (0..*)
				condition foo_bar:
					required choice foo, bar
			type Color:
				 blue boolean (0..1)

		'''.parseRosettaWithNoErrors	
	}
			
	@Test
	def void testAttributeWithMetadataReferenceAnnotation() {
		'''
			metaType reference string
			
			type Foo:
				foo string (1..1)
					[metadata reference]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributeWithMetadataIdAnnotation() {
	'''
			metaType id string

			type Foo:
				foo string (1..1)
					[metadata id]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributeWithMetadataSchemeAnnotation() {
	'''
			metaType scheme string
			metaType reference string

			type Foo:
				foo string (1..1) 
					[metadata scheme]
			
			type Bar:
				bar string (1..1)
					[metadata scheme]
					[metadata reference]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributesWithLocationAndAddress() {
	'''
			metaType scheme string
			metaType reference string

			type Foo:
				foo string (1..1) 
					[metadata location]
			
			type Bar:
				bar string (1..1)
					[metadata address "pointsTo"=Foo->foo]
			
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymsWithPathExpression() {
		'''
			synonym source FpML
			type Foo:
				foo int (0..1)
					[synonym FpML value "foo" path "fooPath1"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void synonymsWithHint() {
		'''
			synonym source FpML
			type Foo:
				foo int (0..1)
					[synonym FpML hint "myHint"]
		'''.parseRosettaWithNoErrors
	}
		
	@Test
	def void testSynonymMappingSetToBoolean() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
					[synonym FpML set to True when "FooSyn" exists]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetToString() {
		'''
			synonym source FpML
			type Foo:
				foo string (0..1)
					[synonym FpML set to "A" when "FooSyn" exists]
			
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetToEnum() {
		'''
			synonym source FpML
			type Foo:
				foo BarEnum (0..1)
					[synonym FpML set to BarEnum -> a when "FooSyn" exists]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingDefaultToEnum() {
		'''
			synonym source FpML
			type Foo:
				foo BarEnum (0..1)
					[synonym FpML value "FooSyn" default to BarEnum -> a]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenEqualsCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
					[synonym FpML value "FooSyn" set when "path->to->string" = BarEnum -> a]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenExistsCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
				[synonym FpML value "FooSyn" set when "path->to->string" exists]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenIsAbsentCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
				[synonym FpML value "FooSyn" set when "path->to->string" is absent]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingMultipleSetToWhenConditions() {
		'''
			synonym source FpML
			type Foo:
				foo string (0..1)
					[synonym FpML
							set to "1" when "path->to->string" = "Foo",
							set to "2" when "path->to->enum" = BarEnum -> a,
							set to "3" when "path->to->string" is absent,
							set to "4"]

			enum BarEnum: a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testClassSynonym() {
	'''
			synonym source FpML
			
			type Foo:
				[synonym FpML value "FooSyn"]
				bar boolean (1..1)
			
		'''.parseRosettaWithNoErrors
	}

	@Test @Disabled //FIXME support "and Foo_Bar apply" ?
	def void testIsProduct() {
	'''
			isProduct FooBar
				[synonym Bank_A value "Foo_Bar"]
				[synonym Venue_B value "BarFoo"]
				Foo -> foo exists
					and ( Foo -> bar is absent
						or Foo -> foo <> Foo -> foo  )
				and Foo_Bar apply
				
			type Foo:
				foo string (1..1)
				bar Bar (0..1)
				condition Foo_Bar:
					if foo exists
						then Foo is absent
			
			type Bar:
				bar string (1..1)

		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithMapperShouldParseWithNoErrors() {
	'''
			type Foo:
				foo string (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" mapper "BarToFooMapper"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithFormatShouldParseWithNoErrors() {
	'''
			type Foo:
				foo date (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" dateFormat "MM/dd/yy"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithPattenShouldParseWithNoErrors() {
	 '''
			type Foo:
				foo int (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" pattern "([0-9])*.*" "$1"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalEnumSynonymWithPattenShouldParseWithNoErrors() {
	'''
			enum Foo:
				FOO
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
			enums	
				Foo:
					+ FOO
						[value "bar" pattern "([0-9])*.*" "/$1"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithMetaShouldParseWithNoErrors() {
	'''
			metaType scheme string
			
			type Foo:
				foo string (0..1)
				[metadata scheme]
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" meta "barScheme"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithRemoveHtmlShouldParseWithNoErrors() {
	'''
			type Foo:
				foo string (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" removeHtml]
			}
		'''.parseRosettaWithNoErrors
	}
}
