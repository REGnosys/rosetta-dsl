package com.regnosys.rosetta.generator.java.object

import com.google.inject.Inject
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.CodeGeneratorTestHelper
import com.regnosys.rosetta.tests.util.ModelHelper
import com.rosetta.model.lib.annotations.RosettaSynonym
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import com.regnosys.rosetta.rosetta.simple.Data

import static org.hamcrest.CoreMatchers.*
import static org.hamcrest.MatcherAssert.*

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class SynonymGeneratorTest {

	@Inject extension ModelHelper
	@Inject extension CodeGeneratorTestHelper

	@Test
	def void shouldSetManyToTrueWhenFlagSet() {
		val resource = '''
			type Test :
				attr string (1..1)
					[synonym FpML value "testSynonym" maps 2]
		'''

		val classes = resource.compileJava8
		val testClass = classes.get(rootPackage.name + '.Test')
		val synonym = testClass.getMethod('getAttr').annotations.filter(RosettaSynonym).findFirst[maps > 1]

		assertThat(synonym.value, is('testSynonym'))
	}

	@Test
	def void shouldSetManyToFalseWhenFlagNotSet() {
		val resource = '''
			type Test :
				attr string (1..1)
					[synonym FpML value "testSynonym"]
		'''

		val classes = resource.compileJava8
		val testClass = classes.get(rootPackage.name + '.Test')
		val synonym = testClass.getMethod('getAttr').annotations.filter(RosettaSynonym).findFirst[maps > 1]

		assertThat(synonym, nullValue())
	}
	
	@Test
	def void shouldParseListOfSynonymSources() {
		'''
			type Test:
				attr string (1..1)
					[synonym FpML, DTCC value "testSynonym"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void shouldGenerateMultipleRosettaSynonyms() {
		val code = '''
			type Test:
				attr string (1..1)
					[synonym FpML, DTCC value "testSynonym"]
		'''.generateCode
		
		val testClass = code.get(rootPackage.name + '.Test')
		
		val expectedFpML = '@RosettaSynonym(value="testSynonym", source="FpML")'
		val expectedDTCC = '@RosettaSynonym(value="testSynonym", source="DTCC")'
			
		assertThat(testClass, allOf(containsString(expectedFpML), containsString(expectedDTCC)))
	}
	
	@Test
	def void shouldGenerateMultipleRosettaSynonymsWithSinglePathExpression() {
		val code = '''
			type Test :
				attr string (1..1)
					[synonym FpML, DTCC value "testSynonym" path "synonym->path->s"]
		'''.generateCode
		
		val testClass = code.get(rootPackage.name + '.Test')
		
		val expectedFpML = '@RosettaSynonym(value="testSynonym", source="FpML", path="synonym->path->s")'
		val expectedDTCC = '@RosettaSynonym(value="testSynonym", source="DTCC", path="synonym->path->s")'
			
		assertThat(testClass, allOf(containsString(expectedFpML), containsString(expectedDTCC)))
	}
	
	@Test
	def void shouldGenerateRosettaSynonymsWithMetaId() {
		val code = '''
			namespace «rootPackage.name»
			type Test:
				[metadata key]
				[synonym FpML meta "id"]
			
				adjustedDate date (0..1)
					[metadata id]
					// synonym "adjustedDate" and "adjustedDate->id"
					[synonym FpML value "adjustedDate" meta "id"]
					// synonym "relativeDate->adjustedDate" and "relativeDate->adjustedDate->id"
					[synonym FpML value "adjustedDate" path "relativeDate" meta "id"]
		'''.generateCode
		
		val testClass = code.get(rootPackage.name + '.Test')
				
		// attribute adjustedDate
		assertThat(testClass, containsString('@RosettaSynonym(value="adjustedDate", source="FpML")'))
		assertThat(testClass, containsString('@RosettaSynonym(value="adjustedDate", source="FpML", path="relativeDate")'))

	}
	
	@Test
	def void shouldGenerateRosettaSynonymsWithOnlyMetaId() {
		val code = '''
			namespace «rootPackage.name»
			type Test:
			
				adjustedDate date (0..1)
					[metadata id]
					[synonym FpML meta "id"]
		'''.parseRosettaWithNoErrors
		
		val syn = code.elements.filter(Data).findFirst[name=="Test"].attributes.findFirst[name=="adjustedDate"].synonyms.get(0);
		assertThat(syn.body, notNullValue)
		assertThat(syn.body.metaValues.get(0), is("id"))
	}
}
