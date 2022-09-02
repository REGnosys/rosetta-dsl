package com.regnosys.rosetta.generator.java.expression

import com.google.common.collect.ImmutableList
import com.google.inject.Inject
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.CodeGeneratorTestHelper
import com.rosetta.model.lib.RosettaModelObject
import java.math.BigDecimal
import java.util.Arrays
import java.util.Map
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static com.google.common.collect.ImmutableMap.*
import static org.hamcrest.MatcherAssert.*
import static org.hamcrest.core.Is.is
import com.regnosys.rosetta.generator.java.function.FunctionGeneratorHelper
import org.junit.jupiter.api.Disabled

@Disabled
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaExistsExpressionTest {

	@Inject extension CodeGeneratorTestHelper
	@Inject extension FunctionGeneratorHelper

	Map<String, Class<?>> classes

	@BeforeEach
	def void setUp() {
		val code = '''
			type Foo:
				bar Bar (0..*)
				baz Baz (0..1)
			
			type Bar:
				before number (0..1)
				after number (0..1)
				other number (0..1)
				beforeWithScheme number (0..1)
					[metadata scheme]
				afterWithScheme number (0..1)
					[metadata scheme]
				beforeList number (0..*)
				afterList number (0..*)
				beforeListWithScheme number (0..*)
					[metadata scheme]
				afterListWithScheme number (0..*)
					[metadata scheme]
			
			type Baz:
				bazValue number (0..1)
				other number (0..1)
			
			func Exists:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					foo -> bar -> before exists
			
			func SingleExists:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					foo -> bar -> before single exists
			
			func MultipleExists:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					foo -> bar -> before multiple exists
			
			func OnlyExists:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					foo -> bar -> before only exists
			
			func OnlyExistsMultiplePaths:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> before, foo -> bar -> after ) only exists
			
			func OnlyExistsPathWithScheme:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> before, foo -> bar -> afterWithScheme ) only exists
			
			func OnlyExistsBothPathsWithScheme:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> beforeWithScheme, foo -> bar -> afterWithScheme ) only exists
			
			func OnlyExistsListMultiplePaths:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> before, foo -> bar -> afterList ) only exists
			
			func OnlyExistsListPathWithScheme:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> before, foo -> bar -> afterListWithScheme ) only exists
			
			func OnlyExistsListBothPathsWithScheme:
				inputs: foo Foo (1..1)
				output: result boolean (1..1)
				set result:
					( foo -> bar -> beforeListWithScheme, foo -> bar -> afterListWithScheme ) only exists
			
			«««			TODO tests compilation only, add unit test
			func MultipleSeparateOr_No	liases_Exists:
				inputs: foo Fo	 (1..1)
				out	ut: result boolean (1..1)
				set result:
					foo -> bar -> bere exists or foo -> bar -> after exists

«««			TODO tests compilation only, add unit test
			func MultipleOr_No liases_Exists:
				inputs: foo Fo  (1..1)
				out ut: result boolean (1..1)
				set result:
					foo -> bar -> before exists or foo -> bar -> after exists or foo -> baz -> other exists
			
«««			TODO tests compilation only, add unit test
			func MultipleOrBranchNode_Nofliases_Exists:
				inputs: foo Fof (1..1)
				outfut: result boolean (1..1)
				set result:
					foo -> bar exists or foo -> baz exists
			
«««			TODO tests compilation only, add unit test
			func MultipleAnd_Notliases_Exists:
				inputs: foo Fot (1..1)
				outtut: result boolean (1..1)
				set result:
					foo -> bar -> before exists and foo -> bar -> after exists and foo -> baz -> other exists
			
«««			TODO tests compilation only, add unit test
			func MultipleOrAnd_Nosliases_Exists:
				inputs: foo Fos (1..1)
				outsut: result boolean (1..1)
				set result:
					foo -> bar -> before exists or ( foo -> bar -> after exists and foo -> baz -> other exists )
			
«««			TODO tests compilation only, add unit test
			func MultipleOrAnd_NoAtiases_Exists2:
				inputs: foo Fot (1..1)
				outtut: result boolean (1..1)
				set result:
					(foo -> bar -> before exists and foo -> bar -> after exists) or foo -> baz -> other exists or foo -> baz -> bazValue exists
			
«««			TODO tests compilation only, add unit test
			func MultipleOrAnd_NoAtiases_Exists3:
				inputs: foo Fot (1..1)
				outtut: result boolean (1..1)
				set result:
					(foo -> bar -> before exists or foo -> bar -> after exists) or (foo -> baz -> other exists and foo -> baz -> bazValue exists)
			
«««			TODO tests compilation only, add unit test
			func MultipleEuistsWithOrAnd:
				inputs: foo Fou (1..1)
				outuut: result boolean (1..1)
				set result:
					foo -> bar -> before exists or ( foo -> baz -> other exists and foo -> bar -> after exists ) or foo -> baz -> bazValue exists
			'''.generateCode
		// println(code)
		// .writeClasses("RosettaQualifyEventsExistsTest")
		classes = code.compileToClasses
	}

	@Test
	def shouldGenerateFuncWithExistsAndSingleExists() {
		val bar = classes.createInstanceUsingBuilder('Bar', of('before', BigDecimal.valueOf(15)), of())
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("Exists", foo, true)
		assertResult("SingleExists", foo, true)
	}

	@Test
	def shouldGenerateFuncWithOnlyExists1() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('before', BigDecimal.valueOf(15)),
			of()
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExists", foo, true)
		assertResult("OnlyExistsMultiplePaths", foo, false)
		assertResult("OnlyExistsPathWithScheme", foo, false)
		assertResult("OnlyExistsBothPathsWithScheme", foo, false)
	}

	@Test
	def shouldGenerateFuncWithOnlyExists2() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('before', BigDecimal.valueOf(15), 'after', BigDecimal.valueOf(20)),
			of()
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExists", foo, false)
		assertResult("OnlyExistsMultiplePaths", foo, true)
		assertResult("OnlyExistsPathWithScheme", foo, false)
		assertResult("OnlyExistsBothPathsWithScheme", foo, false)
	}

	@Test
	def shouldGenerateFuncWithOnlyExists3() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('before', BigDecimal.valueOf(15), 'afterWithSchemeValue', BigDecimal.valueOf(20)),
			of()
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExists", foo, false)
		assertResult("OnlyExistsMultiplePaths", foo, false)
		assertResult("OnlyExistsPathWithScheme", foo, true)
		assertResult("OnlyExistsBothPathsWithScheme", foo, false)
	}

	@Test
	def shouldGenerateFuncWithOnlyExists4() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('beforeWithSchemeValue', BigDecimal.valueOf(15), 'afterWithSchemeValue', BigDecimal.valueOf(20)),
			of()
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExists", foo, false)
		assertResult("OnlyExistsMultiplePaths", foo, false)
		assertResult("OnlyExistsPathWithScheme", foo, false)
		assertResult("OnlyExistsBothPathsWithScheme", foo, true)
	}

	@Test
	def shouldGenerateFuncWithOnlyExists5() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('before', BigDecimal.valueOf(15)),
			of('afterList', Arrays.asList(BigDecimal.valueOf(20), BigDecimal.valueOf(21)))
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExistsListMultiplePaths", foo, true)
		assertResult("OnlyExistsListPathWithScheme", foo, false)
		assertResult("OnlyExistsListBothPathsWithScheme", foo, false)
	}

	@Test
	def shouldNotQualifyOnlyExists() {
		val bar = classes.createInstanceUsingBuilder(
			'Bar',
			of('before', BigDecimal.valueOf(15), 'after', BigDecimal.valueOf(20), 'other', BigDecimal.valueOf(25)),
			of()
		)
		val foo = RosettaModelObject.cast(
			classes.createInstanceUsingBuilder('Foo', of(), of('bar', ImmutableList.of(bar))))

		assertResult("OnlyExists", foo, false)
		assertResult("OnlyExistsMultiplePaths", foo, false)
	}

	// Util methods
	def assertResult(String funcName, RosettaModelObject input, boolean expectedResult) {
		val func = classes.createFunc(funcName);
		val res = func.invokeFunc(Boolean, input)
		assertThat(res, is(expectedResult))
	}
}
