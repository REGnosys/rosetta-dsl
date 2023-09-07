/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.tests

import com.regnosys.rosetta.tests.util.CodeGeneratorTestHelper
import com.regnosys.rosetta.tests.util.ModelHelper
import com.regnosys.rosetta.validation.RosettaIssueCodes
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static com.regnosys.rosetta.rosetta.expression.ExpressionPackage.Literals.*
import static org.hamcrest.CoreMatchers.*
import static org.hamcrest.MatcherAssert.*
import static extension org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Disabled
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.expression.RosettaConditionalExpression
import org.eclipse.emf.ecore.util.EcoreUtil.EqualityHelper
import com.regnosys.rosetta.rosetta.expression.ExpressionFactory
import javax.inject.Inject

/**
 * A set of tests for all instances of RosettaExpression i.e. RosettaAdditiveExpression
 */
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaExpressionsTest {

	@Inject extension CodeGeneratorTestHelper
	@Inject extension ModelHelper
	@Inject extension ValidationTestHelper
	@Inject EqualityHelper eqHelper;
	
	
	@Test
	def void absentElseBranchShouldBeSyntacticSugarForEmptyListLiteral() {
		val model = '''
			func AbsentElseSyntacticSugar:
				output: result int (0..1)
				set result:
					if True then 0
		'''.parseRosettaWithNoErrors
		
		model => [
			((elements.last as Function)
			  .operations.head.expression as RosettaConditionalExpression) => [
			  	assertFalse(isFull);
			  	assertNotNull(elsethen);
			  	val lit = ExpressionFactory.eINSTANCE.createListLiteral
			  	lit.generated = true
			  	assertTrue(eqHelper.equals(elsethen, lit))
			  ]
		]
	}
	
	@Test
	def void shouldParseQualifierWithAdditiveExpression() {
		'''
			type Test:
				one number (1..1)
				two number (1..1)
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one + test -> two = 42
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void shouldParseNoIssuesWhenDateSubtraction() {
		'''
			type Test:
				one date (1..1)
				two date (1..1)
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one - test -> two = 42
		'''.parseRosettaWithNoErrors.assertNoIssues
	}
	
	@Test
	def void shouldParseWithErrorWhenAddingDates() {
		'''
			type Test:
				one date (1..1)
				two date (1..1)
			
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one + test -> two = 42
		'''.parseRosetta.assertError(ROSETTA_BINARY_OPERATION, RosettaIssueCodes.TYPE_ERROR, "Incompatible types: cannot use operator '+' with date and date.")
	}
	
	/**
	 * The openjdk 11 compiler requires extra generics information for compilation. Eclipse compiler doesn't need this 
	 * so you will get a nice surprise when you build your generated code using javac compiler (Maven and IntelliJ).
	 */
	@Test
	def void shouldCodeGenerateWithMoreGenericsInformation() {
		val code = '''
			type Test:
				one date (1..1)
				two date (1..1)
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one - test -> two = 42
		'''.generateCode

		val qualifier = code.get("com.rosetta.test.model.functions.TestQualifier")
		assertThat(qualifier, containsString("MapperMaths.<Integer, Date, Date>subtract"))
	}
	
	@Test
	@Disabled
	def void shoudCodeGenerateAndCompileWhenSubtractingDates() {
		val code = '''
			type Test:
				one date (1..1)
				two date (1..1)
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one - test -> two = 42
		'''.generateCode
		
		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileWhenAddingNumbers() {
		val code = '''
			type Test:
				one number (1..1)
				two int (1..1)
			
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one + test -> two = 42
		'''.generateCode

		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessingMetaSimple() {
		val code = '''
			type Test:
				one string (1..1)
					[metadata scheme]
				two int (1..1)
			
			func TestQualifier:
				inputs: test Test (1..1)
				output: result boolean (1..1)
				set result:
					test -> one -> scheme = "scheme"
		'''.generateCode
		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessingMeta() {
		val code = '''
			type Test:
				one Foo (1..1)
					[metadata scheme]
				two int (1..1)
			
			type Foo:
				one string (1..1)
					[metadata scheme]
				two int (1..1)
			
			func TestQualifier:
				inputs: test Test(1..1)
				output: is_product boolean (1..1)
				set is_product:
					test -> one -> scheme = "scheme"
		'''.generateCode

		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessPastMeta() {
		val code = '''
			type Test:
				one Foo (1..1)
					[metadata scheme]
				two int (1..1)
			
			type Foo:
				one string (1..1)
					[metadata scheme]
				two int (1..1)
			
			func TestQualifier:
				inputs: test Test(1..1)
				output: is_product boolean (1..1)
				set is_product:
					test -> one -> one = "scheme"
		'''.generateCode

		code.compileToClasses
	}
}
