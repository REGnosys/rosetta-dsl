package com.regnosys.rosetta.generator.java.expression

import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.java.function.CardinalityProvider
import com.regnosys.rosetta.generator.java.util.ImportManagerExtension
import com.regnosys.rosetta.generator.java.util.JavaNames
import com.regnosys.rosetta.generator.java.types.JavaType
import com.regnosys.rosetta.generator.util.RosettaAttributeExtensions
import com.regnosys.rosetta.generator.util.RosettaFunctionExtensions
import com.regnosys.rosetta.generator.util.Util
import com.regnosys.rosetta.rosetta.expression.RosettaAbsentExpression
import com.regnosys.rosetta.rosetta.expression.RosettaBigDecimalLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaBinaryOperation
import com.regnosys.rosetta.rosetta.expression.RosettaBooleanLiteral
import com.regnosys.rosetta.rosetta.RosettaCallableWithArgs
import com.regnosys.rosetta.rosetta.expression.RosettaConditionalExpression
import com.regnosys.rosetta.rosetta.expression.RosettaCountOperation
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.expression.RosettaExistsExpression
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import com.regnosys.rosetta.rosetta.RosettaExternalFunction
import com.regnosys.rosetta.rosetta.RosettaFeature
import com.regnosys.rosetta.rosetta.expression.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.expression.RosettaIntLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaLiteral
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.expression.RosettaOnlyExistsExpression
import com.regnosys.rosetta.rosetta.expression.RosettaStringLiteral
import com.regnosys.rosetta.rosetta.RosettaType
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.expression.ClosureParameter
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.expression.ListLiteral
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.types.RosettaOperators
import com.regnosys.rosetta.types.RosettaTypeProvider
import com.regnosys.rosetta.utils.ExpressionHelper
import com.rosetta.model.lib.expression.CardinalityOperator
import com.rosetta.model.lib.expression.ComparisonResult
import com.rosetta.model.lib.expression.ExpressionOperators
import com.rosetta.model.lib.expression.MapperMaths
import com.rosetta.model.lib.mapper.MapperC
import com.rosetta.model.lib.mapper.MapperS
import java.math.BigDecimal
import org.eclipse.xtend2.lib.StringConcatenationClient
import org.eclipse.xtext.EcoreUtil2

import static extension com.regnosys.rosetta.generator.java.enums.EnumHelper.convertValues
import static extension com.regnosys.rosetta.generator.java.util.JavaClassTranslator.toJavaClass
import static extension com.regnosys.rosetta.generator.java.util.JavaClassTranslator.toJavaType
import java.util.Arrays
import com.regnosys.rosetta.rosetta.expression.FilterOperation
import com.regnosys.rosetta.rosetta.expression.NamedFunctionReference
import com.regnosys.rosetta.rosetta.expression.InlineFunction
import com.regnosys.rosetta.rosetta.expression.MapOperation
import com.regnosys.rosetta.rosetta.expression.FlattenOperation
import com.regnosys.rosetta.rosetta.expression.DistinctOperation
import com.regnosys.rosetta.rosetta.expression.SumOperation
import com.regnosys.rosetta.rosetta.expression.MinOperation
import com.regnosys.rosetta.rosetta.expression.MaxOperation
import com.regnosys.rosetta.rosetta.expression.SortOperation
import com.regnosys.rosetta.rosetta.expression.ReverseOperation
import com.regnosys.rosetta.rosetta.expression.ReduceOperation
import com.regnosys.rosetta.rosetta.expression.RosettaUnaryOperation
import com.regnosys.rosetta.rosetta.expression.FirstOperation
import com.regnosys.rosetta.rosetta.expression.LastOperation
import com.regnosys.rosetta.rosetta.expression.RosettaFunctionalOperation
import com.regnosys.rosetta.rosetta.expression.ExistsModifier
import com.regnosys.rosetta.rosetta.expression.RosettaOnlyElement
import com.regnosys.rosetta.rosetta.expression.ModifiableBinaryOperation
import com.regnosys.rosetta.rosetta.expression.CardinalityModifier
import com.regnosys.rosetta.rosetta.expression.LogicalOperation
import com.regnosys.rosetta.rosetta.expression.RosettaContainsExpression
import com.regnosys.rosetta.rosetta.expression.RosettaDisjointExpression
import com.regnosys.rosetta.rosetta.expression.ComparisonOperation
import com.regnosys.rosetta.rosetta.expression.EqualityOperation
import com.regnosys.rosetta.rosetta.expression.ExtractAllOperation
import org.eclipse.emf.ecore.EObject
import com.regnosys.rosetta.rosetta.expression.RosettaReference
import com.regnosys.rosetta.utils.ImplicitVariableUtil
import com.regnosys.rosetta.rosetta.expression.RosettaImplicitVariable
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference
import java.util.List
import com.regnosys.rosetta.rosetta.RosettaRecordFeature
import com.regnosys.rosetta.generator.util.RecordFeatureMap
import com.regnosys.rosetta.rosetta.expression.AsKeyOperation
import com.regnosys.rosetta.rosetta.expression.OneOfOperation
import com.regnosys.rosetta.rosetta.expression.ChoiceOperation
import com.regnosys.rosetta.rosetta.expression.Necessity
import com.rosetta.model.lib.validation.ValidationResult.ChoiceRuleValidationMethod
import com.regnosys.rosetta.types.RDataType
import com.regnosys.rosetta.generator.java.JavaScope
import com.regnosys.rosetta.generator.java.BlueprintImplicitVariableRepresentation

class ExpressionGenerator {
	
	@Inject protected RosettaTypeProvider typeProvider
	@Inject RosettaOperators operators
	@Inject extension CardinalityProvider cardinalityProvider
	@Inject JavaNames.Factory factory 
	@Inject RosettaFunctionExtensions funcExt
	@Inject extension RosettaExtensions
	@Inject extension ImportManagerExtension
	@Inject ExpressionHelper exprHelper
	@Inject extension Util
	@Inject extension ListOperationExtensions
	@Inject extension ImplicitVariableUtil
	@Inject RecordFeatureMap recordFeatureMap
	
	/**
	 * convert a rosetta expression to code
	 * ParamMpa params  - a map keyed by classname or positional index that provides variable names for expression parameters
	 */
	def StringConcatenationClient javaCode(RosettaExpression expr, JavaScope scope) {
		switch (expr) {
			RosettaFeatureCall: {
				featureCall(expr, scope)
			}
			RosettaOnlyExistsExpression: {
				onlyExistsExpr(expr, scope)
			}
			RosettaExistsExpression: {
				existsExpr(expr, scope)
			}
			RosettaBinaryOperation: {
				binaryExpr(expr, null, scope)
			}
			RosettaCountOperation: {
				countExpr(expr, null, scope)
			}
			RosettaAbsentExpression: {
				absentExpr(expr, expr.argument, scope)
			}
			RosettaReference: {
				reference(expr, scope)
			}
			RosettaBigDecimalLiteral : {
				'''«MapperS».of(new «BigDecimal»("«expr.value»"))'''
			}
			RosettaBooleanLiteral : {
				'''«MapperS».of(Boolean.valueOf(«expr.value»))'''
			}
			RosettaIntLiteral : {
				'''«MapperS».of(Integer.valueOf(«expr.value»))'''
			}
			RosettaStringLiteral : {
				'''«MapperS».of("«expr.value»")'''
			}
			RosettaEnumValueReference : {
				'''«MapperS».of(«expr.enumeration.toJavaType».«expr.value.convertValues»)'''
			}
			RosettaConditionalExpression : {
				'''«expr.genConditionalMapper(scope)»'''
			}
			ListLiteral : {
				listLiteral(expr, scope)
			}
			DistinctOperation : {
				distinctOperation(expr, scope)
			}
			FirstOperation : {
				firstOperation(expr, scope)
			}
			FlattenOperation : {
				flattenOperation(expr, scope)
			}
			LastOperation : {
				lastOperation(expr, scope)
			}
			MaxOperation : {
				maxOperation(expr, scope)
			}
			MinOperation : {
				minOperation(expr, scope)
			}
			SumOperation : {
				sumOperation(expr, scope)
			}
			ReverseOperation : {
				reverseOperation(expr, scope)
			}
			RosettaOnlyElement : {
				onlyElement(expr, scope)
			}
			ReduceOperation : {
				reduceOperation(expr, scope)
			}
			FilterOperation : {
				filterOperation(expr, scope)
			}
			MapOperation : {
				mapOperation(expr, scope)
			}
			ExtractAllOperation : {
				extractAllOperation(expr, scope)
			}
			SortOperation : {
				sortOperation(expr, scope)
			}
			AsKeyOperation: {
				// this operation is currently handled by the `FunctionGenerator`
				expr.argument.javaCode(scope)
			}
			OneOfOperation: {
				oneOfOperation(expr, scope)
			}
			ChoiceOperation: {
				choiceOperation(expr, scope)
			}
			default: 
				throw new UnsupportedOperationException("Unsupported expression type of " + expr?.class?.simpleName)
		}
	}
	
	private def runtimeMethod(String methodName) {
		return importWildcard(method(ExpressionOperators, methodName))
	}
	
	private def StringConcatenationClient emptyToMapperJavaCode(RosettaExpression expr, JavaScope scope, boolean multi) {
		if (expr.isEmpty) {
			'''«IF multi»«MapperC»«ELSE»«MapperS»«ENDIF».ofNull()'''
		} else {
			expr.javaCode(scope)
		}
	}
	
	def StringConcatenationClient listLiteral(ListLiteral e, JavaScope scope) {
	    if (e.isEmpty) {
	        '''null'''
	    } else {
	       '''«MapperC».of(«FOR ele: e.elements SEPARATOR ', '»«ele.javaCode(scope)»«ENDFOR»)'''
	    }
	}
	
	private def boolean isEmpty(RosettaExpression e) { // TODO: temporary workaround while transitioning from old to new type system
	    if (e instanceof ListLiteral) {
	        e.elements.size === 0
	    } else {
	        false
	    }
	}

	private def StringConcatenationClient genConditionalMapper(RosettaConditionalExpression expr, JavaScope scope)'''
		«IF expr.ifthen.evaluatesToComparisonResult»com.rosetta.model.lib.mapper.MapperUtils.toComparisonResult(«ENDIF»com.rosetta.model.lib.mapper.MapperUtils.«IF funcExt.needsBuilder(expr.ifthen)»fromDataType«ELSE»fromBuiltInType«ENDIF»(() -> {
			«expr.genConditional(scope)»
		})«IF expr.ifthen.evaluatesToComparisonResult»)«ENDIF»'''



	private def StringConcatenationClient genConditional(RosettaConditionalExpression expr, JavaScope scope) {
		return  '''
			if («expr.^if.javaCode(scope)».get()) {
				return «expr.ifthen.javaCode(scope)»;
			}
			«IF expr.childElseThen !== null»
				«expr.childElseThen.genElseIf(scope)»
			«ELSE»
				else {
					return «expr.elsethen.emptyToMapperJavaCode(scope, cardinalityProvider.isMulti(expr.ifthen))»;
				}
			«ENDIF»
			'''
	}

	private def StringConcatenationClient genElseIf(RosettaConditionalExpression next, JavaScope scope) {
		'''
		«IF next !== null»
			else if («next.^if.javaCode(scope)».get()) {
				return «next.ifthen.javaCode(scope)»;
			}
			«IF next.childElseThen !== null»
				«next.childElseThen.genElseIf(scope)»
			«ELSE»
				else {
					return «next.elsethen.emptyToMapperJavaCode(scope, cardinalityProvider.isMulti(next.ifthen))»;
				}
			«ENDIF»
		«ENDIF»
		'''
	}

	private def RosettaConditionalExpression childElseThen(RosettaConditionalExpression expr) {
		if (expr.elsethen instanceof RosettaConditionalExpression)
			expr.elsethen as RosettaConditionalExpression
	}
	
	private def StringConcatenationClient callableWithArgs(RosettaCallableWithArgs callable, JavaScope scope, StringConcatenationClient argsCode, boolean needsMapper) {		
		return switch (callable) {
			Function: {
				val multi = funcExt.getOutput(callable).card.isMany
				'''«IF needsMapper»«IF multi»«MapperC»«ELSE»«MapperS»«ENDIF».of(«ENDIF»«callable.name.toFirstLower».evaluate(«argsCode»)«IF needsMapper»)«ENDIF»'''
			}
			RosettaExternalFunction: {
				'''«IF needsMapper»«MapperS».of(«ENDIF»new «factory.create(callable.model).toJavaType(callable)»().execute(«argsCode»)«IF needsMapper»)«ENDIF»'''
			}
			default: 
				throw new UnsupportedOperationException("Unsupported callable with args of type " + callable?.eClass?.name)
		}
		
	}
	
	def StringConcatenationClient callableWithArgsCall(RosettaCallableWithArgs func, List<RosettaExpression> arguments, JavaScope scope) {
		callableWithArgs(func, scope, '''«args(arguments, scope)»''', true)
	}
	
	private def StringConcatenationClient args(List<RosettaExpression> arguments, JavaScope scope) {
		'''«FOR argExpr : arguments SEPARATOR ', '»«arg(argExpr, scope)»«ENDFOR»'''
	}
	
	private def StringConcatenationClient arg(RosettaExpression expr, JavaScope scope) {
		'''«expr.javaCode(scope)»«IF expr.evalulatesToMapper»«IF cardinalityProvider.isMulti(expr)».getMulti()«ELSE».get()«ENDIF»«ENDIF»'''
	}
	
	def StringConcatenationClient onlyExistsExpr(RosettaOnlyExistsExpression onlyExists, JavaScope scope) {
		'''«runtimeMethod('onlyExists')»(«Arrays».asList(«FOR arg : onlyExists.args SEPARATOR ', '»«arg.javaCode(scope)»«ENDFOR»))'''
	}
	
	def StringConcatenationClient existsExpr(RosettaExistsExpression exists, JavaScope scope) {
		val arg = exists.argument
		val binary = arg.findBinaryOperation
		if (binary !== null) {
			if(binary.isLogicalOperation)
				'''«doExistsExpr(exists, arg.javaCode(scope))»'''
			else 
				//if the argument is a binary expression then the exists needs to be pushed down into it
				binary.binaryExpr(exists, scope)
		}
		else {
			'''«doExistsExpr(exists, arg.javaCode(scope))»'''
		}
	}
	
	def RosettaBinaryOperation findBinaryOperation(RosettaExpression expression) {
		switch(expression) {
			RosettaBinaryOperation: expression
			default: null
		}
	}
	
	private def StringConcatenationClient doExistsExpr(RosettaExistsExpression exists, StringConcatenationClient arg) {
		if(exists.modifier === ExistsModifier.SINGLE)
			'''«runtimeMethod('singleExists')»(«arg»)'''
		else if(exists.modifier === ExistsModifier.MULTIPLE)
			'''«runtimeMethod('multipleExists')»(«arg»)'''
		else
			'''«runtimeMethod('exists')»(«arg»)'''
	}

	def StringConcatenationClient absentExpr(RosettaAbsentExpression notSet, RosettaExpression argument, JavaScope scope) {
		val arg = argument
		val binary = arg.findBinaryOperation
		if (binary !== null) {
			if(binary.isLogicalOperation)
				'''«runtimeMethod('notExists')»(«binary.binaryExpr(notSet, scope)»)'''
			else
				//if the arg is binary then the operator needs to be pushed down
				binary.binaryExpr(notSet, scope)
		}
		else {
			'''«runtimeMethod('notExists')»(«arg.javaCode(scope)»)'''
		}
	}
	
	private def StringConcatenationClient implicitVariable(EObject context, JavaScope scope) {
		val definingContainer = context.findContainerDefiningImplicitVariable.get
		if (definingContainer instanceof Data) {
			// For conditions
			return '''«MapperS».of(«definingContainer.getName.toFirstLower»)'''
		} else {
			// For inline functions
			return '''«defaultImplicitVariable.name.toDecoratedName(definingContainer)»'''
		}
	}
	
	protected def StringConcatenationClient reference(RosettaReference expr, JavaScope scope) {
		switch (expr) {
			RosettaImplicitVariable: {
				implicitVariable(expr, scope)
			}
			RosettaSymbolReference: {
				val s = expr.symbol
				switch (s)  {
					Data: { // -------> replace with call to implicit variable?
						'''«MapperS».of(«scope.getIdentifier(new BlueprintImplicitVariableRepresentation(s))»)'''
					}
					Attribute: {
						// Data attributes can only be called if there is an implicit variable present.
						// The current container (Data) is stored in Params, but we need also look for superTypes
						// so we could also do: (s.eContainer as Data).allSuperTypes.map[it|params.getClass(it)].filterNull.head
						val implicitType = typeProvider.typeOfImplicitVariable(expr)
						val implicitFeatures = implicitType.allFeatures
						if(implicitFeatures.contains(s)) {
							var autoValue = true //if the attribute being referenced is WithMeta and we aren't accessing the meta fields then access the value by default
							if (expr.eContainer instanceof RosettaFeatureCall && (expr.eContainer as RosettaFeatureCall).feature instanceof RosettaMetaType) {
								autoValue = false;
							}
							featureCall(implicitVariable(expr, scope), s, scope, autoValue, expr)
						}
						else
							'''«if (s.card.isIsMany) MapperC else MapperS».of(«s.name»)'''
					}
					ShortcutDeclaration: {
						val multi = cardinalityProvider.isMulti(s)
						'''«IF multi»«MapperC»«ELSE»«MapperS»«ENDIF».of(«s.name»(«aliasCallArgs(s)»).«IF exprHelper.usesOutputParameter(s.expression)»build()«ELSE»«IF multi»getMulti()«ELSE»get()«ENDIF»«ENDIF»)'''
					}
					RosettaEnumeration: '''«s.toJavaType»'''
					ClosureParameter: '''«s.name.toDecoratedName(s.function)»'''
					RosettaCallableWithArgs: {
						callableWithArgsCall(s, expr.args, scope)
					}
					default: 
						throw new UnsupportedOperationException("Unsupported symbol type of " + s?.class?.name)
				}
			}
			default: 
				throw new UnsupportedOperationException("Unsupported reference type of " + expr?.class?.name)
		}
	}
	
	def aliasCallArgs(ShortcutDeclaration alias) {
		val func = EcoreUtil2.getContainerOfType(alias, Function)
		val attrs = <String>newArrayList
		attrs.addAll(funcExt.getInputs(func).map[name].toList)
		if(exprHelper.usesOutputParameter(alias.expression)) {
			attrs.add(0, funcExt.getOutput(func)?.name + '.toBuilder()')
		}
		attrs.join(', ')
	}
	
	/**
	 * feature call is a call to get an attribute of an object e.g. Quote->amount
	 */
	private def StringConcatenationClient featureCall(RosettaFeatureCall call, JavaScope scope) {
		var autoValue = true //if the attribute being referenced is WithMeta and we aren't accessing the meta fields then access the value by default
		if (call.eContainer instanceof RosettaFeatureCall && (call.eContainer as RosettaFeatureCall).feature instanceof RosettaMetaType) {
			autoValue = false;
		}
		return featureCall(javaCode(call.receiver, scope), call.feature, scope, autoValue, call)
	}
	private def StringConcatenationClient featureCall(StringConcatenationClient receiverCode, RosettaFeature feature, JavaScope scope, boolean autoValue, EObject scopeContext) {
		val StringConcatenationClient right = switch (feature) {
			Attribute:
				feature.buildMapFunc(autoValue, scopeContext)
			RosettaMetaType: 
				'''«feature.buildMapFunc(scope)»'''
			RosettaEnumValue: 
				return '''«MapperS».of(«feature.enumeration.toJavaType».«feature.convertValues»)'''
			RosettaRecordFeature:
				'''.map("«feature.name.toFirstUpper»", «recordFeatureMap.recordFeatureToLambda(feature)»)'''
			default: 
				'''.map("get«feature.name.toFirstUpper»", «feature.containerType.toJavaType»::get«feature.name.toFirstUpper»)'''
		}
		
		return '''«receiverCode»«right»'''
	}
	
	private def StringConcatenationClient distinct(StringConcatenationClient code) {
		return '''«runtimeMethod('distinct')»(«code»)'''
	}
	
	def private RosettaType containerType(RosettaFeature feature) {
		EcoreUtil2.getContainerOfType(feature, RosettaType)
	}
	
	def StringConcatenationClient countExpr(RosettaCountOperation expr, RosettaExpression test, JavaScope scope) {
		'''«MapperS».of(«expr.argument.javaCode(scope)».resultCount())'''
	}
	
	def StringConcatenationClient binaryExpr(RosettaBinaryOperation expr, RosettaExpression test, JavaScope scope) {
		val left = expr.left
		val right = expr.right
		val leftRtype = typeProvider.getRType(expr.left)
		val rightRtype = typeProvider.getRType(expr.right)
		val resultType = operators.resultType(expr.operator, leftRtype,rightRtype)
		val leftType = '''«leftRtype.name.toJavaType»'''
		val rightType = '''«rightRtype.name.toJavaType»'''
		
		switch expr.operator {
			case ("and"): {
				'''«left.toComparisonResult(scope)».and(«right.toComparisonResult(scope)»)'''
			}
			case ("or"): {
				'''«left.toComparisonResult(scope)».or(«right.toComparisonResult(scope)»)'''
			}
			case ("+"): {
				'''«MapperMaths».<«resultType.name.toJavaClass», «leftType», «rightType»>add(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("-"): {
				'''«MapperMaths».<«resultType.name.toJavaClass», «leftType», «rightType»>subtract(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("*"): {
				'''«MapperMaths».<«resultType.name.toJavaClass», «leftType», «rightType»>multiply(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("/"): {
				'''«MapperMaths».<«resultType.name.toJavaClass», «leftType», «rightType»>divide(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("contains"): {
				'''«runtimeMethod("contains")»(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("disjoint"): {
				'''«runtimeMethod("disjoint")»(«expr.left.javaCode(scope)», «expr.right.javaCode(scope)»)'''
			}
			case ("join"): {
				'''
				«expr.left.javaCode(scope)»
					.join(«IF expr.right !== null»«expr.right.javaCode(scope)»«ELSE»«MapperS».of("")«ENDIF»)'''
			}
			default: {
				toComparisonOp('''«expr.left.emptyToMapperJavaCode(scope, false)»''', expr.operator, '''«expr.right.emptyToMapperJavaCode(scope, false)»''', (expr as ModifiableBinaryOperation).cardMod)
			}
		}
	}

	def StringConcatenationClient toComparisonResult(RosettaExpression expr, JavaScope scope) {
		val wrap = !expr.evaluatesToComparisonResult
		'''«IF wrap»«ComparisonResult».of(«ENDIF»«expr.javaCode(scope)»«IF wrap»)«ENDIF»'''
	}

	private def boolean isLogicalOperation(RosettaExpression expr) {
		if(expr instanceof RosettaBinaryOperation) return expr.operator == "and" || expr.operator == "or"
		return false
	}
	
	private def boolean isArithmeticOperation(RosettaExpression expr) {
		if(expr instanceof RosettaBinaryOperation) 
			return RosettaOperators.ARITHMETIC_OPS.contains(expr.operator)
		return false
	}
		
	/**
	 * Collects all expressions down the tree, and checks that they're all either FeatureCalls or CallableCalls (or anything that resolves to a Mapper)
	 */
	private def boolean evalulatesToMapper(RosettaExpression expr) { // TODO: this function is faulty, I think
		val exprs = newHashSet
		collectExpressions(expr, [exprs.add(it)])

		return expr.evaluatesToComparisonResult
			|| !exprs.empty
			&& exprs.stream.allMatch[it instanceof RosettaFeatureCall ||
									it instanceof RosettaReference ||
									it instanceof RosettaLiteral ||
									it instanceof ListLiteral && !(it.isEmpty && !(it.eContainer instanceof RosettaConditionalExpression)) ||
									it instanceof RosettaCountOperation ||
									it instanceof RosettaFunctionalOperation ||
									it instanceof RosettaOnlyElement ||
									it instanceof RosettaConditionalExpression ||
									isArithmeticOperation(it)
			]
	}
	private def boolean evaluatesToComparisonResult(RosettaExpression expr) {
		return expr instanceof LogicalOperation
			|| expr instanceof ComparisonOperation
			|| expr instanceof EqualityOperation
			|| expr instanceof RosettaContainsExpression
			|| expr instanceof RosettaDisjointExpression
			|| expr instanceof RosettaOnlyExistsExpression
			|| expr instanceof RosettaExistsExpression
			|| expr instanceof RosettaAbsentExpression
			|| expr instanceof RosettaConditionalExpression && (expr as RosettaConditionalExpression).ifthen.evaluatesToComparisonResult
			|| expr instanceof OneOfOperation
			|| expr instanceof ChoiceOperation
	}
	
	private def StringConcatenationClient toComparisonOp(StringConcatenationClient left, String operator, StringConcatenationClient right, CardinalityModifier cardMod) {
		switch operator {
			case ("="): {
				'''«runtimeMethod('areEqual')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ALL)»)'''
			}
			case ("<>"):
				'''«runtimeMethod('notEqual')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ANY)»)'''
			case ("<") : 
				'''«runtimeMethod('lessThan')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ALL)»)'''
			case ("<=") : 
				'''«runtimeMethod('lessThanEquals')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ALL)»)'''
			case (">") : 
				'''«runtimeMethod('greaterThan')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ALL)»)'''
			case (">=") : 
				'''«runtimeMethod('greaterThanEquals')»(«left», «right», «toCardinalityOperator(cardMod, CardinalityModifier.ALL)»)'''
			default: 
				throw new UnsupportedOperationException("Unsupported binary operation of " + operator)
		}
	}
	
	private def StringConcatenationClient toCardinalityOperator(CardinalityModifier cardOp, CardinalityModifier defaultOp) {
		'''«CardinalityOperator».«if (cardOp === CardinalityModifier.NONE) defaultOp.toString.toFirstUpper else cardOp.toString.toFirstUpper»'''
	}
	
	/**
	 * Builds the expression of mapping functions to extract a path of attributes
	 */
	def StringConcatenationClient buildMapFunc(Attribute attribute, boolean autoValue, EObject container) {
		val mapFunc = attribute.buildMapFuncAttribute(container)
		if (attribute.card.isIsMany) {
			if (attribute.metaAnnotations.nullOrEmpty)
				'''.<«attribute.type.toJavaType»>mapC(«mapFunc»)'''
			else if (!autoValue) {
				'''.<«attribute.metaClass»>mapC(«mapFunc»)'''
			}
			else {
				'''.<«attribute.metaClass»>mapC(«mapFunc»).<«attribute.type.toJavaType»>map("getValue", _f->_f.getValue())'''
			}
		}
		else
		{
			if (attribute.metaAnnotations.nullOrEmpty){
				if(attribute.type instanceof Data) 
				'''.<«attribute.type.toJavaType»>map(«mapFunc»)'''
				else
				'''.<«attribute.type.toJavaType»>map(«mapFunc»)'''
			}
			else if (!autoValue) {
				'''.<«attribute.metaClass»>map(«mapFunc»)'''
			}
			else
				'''.<«attribute.metaClass»>map(«mapFunc»).<«attribute.type.toJavaType»>map("getValue", _f->_f.getValue())'''
		}
	}
	
	private def JavaType toJavaType(RosettaType rosType) {
		val model = rosType.model
		if(model === null)
			throw new IllegalArgumentException('''Can not create type reference. «rosType.eClass?.name» «rosType.name» is not attached to a «RosettaModel.name»''')
		factory.create(model).toJavaType(rosType)
	}
	
	private def javaNames(Attribute attr) {
		val model = EcoreUtil2.getContainerOfType(attr, RosettaModel)
		if(model === null)
			throw new IllegalArgumentException('''Can not create type reference. «attr.eClass?.name» «attr.name» is not attached to a «RosettaModel.name»''')
		factory.create(model)
	}
	
	def JavaType metaClass(Attribute attribute) {
		val names = attribute.javaNames
		val name = if (!attribute.hasMetaFieldAnnotations)  
						if (RosettaAttributeExtensions.isBuiltInType(attribute.type))
							"BasicReferenceWithMeta"+attribute.type.name.toFirstUpper
						else
							"ReferenceWithMeta"+attribute.type.name.toFirstUpper
				   else 
				   		"FieldWithMeta"+attribute.type.name.toFirstUpper
		return names.toMetaType(attribute, name)
	}
	
	def static StringConcatenationClient buildMapFunc(RosettaMetaType meta, JavaScope scope) {
		if (meta.name=="reference") {
			val lambdaScope = scope.childScope
			val lambdaParam = lambdaScope.createUniqueIdentifier("a")
			lambdaScope.close
			'''.map("get«meta.name.toFirstUpper»", «lambdaParam»->«lambdaParam».getGlobalReference())'''
		}
		else {
			val lambdaScope1 = scope.childScope
			val lambdaParam1 = lambdaScope1.createUniqueIdentifier("a")
			lambdaScope1.close
			val lambdaScope2 = scope.childScope
			val lambdaParam2 = lambdaScope1.createUniqueIdentifier("a")
			lambdaScope2.close
			'''.map("getMeta", «lambdaParam1»->«lambdaParam1».getMeta()).map("get«meta.name.toFirstUpper»", «lambdaParam2»->«lambdaParam2».get«meta.name.toFirstUpper»())'''
		}
	}
	
	def dispatch StringConcatenationClient functionReference(NamedFunctionReference ref, JavaScope scope, boolean doCast, boolean needsMapper) {		
		val callable = ref.function
		val inputs = switch (callable) {
			Function: {
				callable.inputs
			}
			RosettaExternalFunction: {
				callable.parameters
			}
			default: 
				throw new UnsupportedOperationException("Unsupported callable with args of type " + callable?.eClass?.name)
		}
		val StringConcatenationClient inputExprs = '''«FOR input: inputs SEPARATOR ', '»«input.name.toDecoratedName(ref)»«IF cardinalityProvider.isMulti(input)».getMulti()«ELSE».get()«ENDIF»«ENDFOR»'''
		val body = callableWithArgs(callable, scope, inputExprs, needsMapper)
		'''(«FOR input: inputs SEPARATOR ', '»«input.name.toDecoratedName(ref)»«ENDFOR») -> «body»'''
	}
	
	def dispatch StringConcatenationClient functionReference(InlineFunction ref, JavaScope scope, boolean doCast, boolean needsMapper) {
		val isBodyMulti =  ref.isBodyExpressionMulti
		val StringConcatenationClient bodyExpr = '''«ref.body.javaCode(scope)»«IF needsMapper»«IF ref.body.evaluatesToComparisonResult».asMapper()«ENDIF»«ELSE»«IF ref.body.evalulatesToMapper»«IF isBodyMulti».getMulti()«ELSE».get()«ENDIF»«ENDIF»«ENDIF»'''
		val StringConcatenationClient cast = if (doCast) {
			val outputType =  ref.bodyRawType
			'''(«IF needsMapper»«IF isBodyMulti»«MapperC»<«outputType»>«ELSE»«MapperS»<«outputType»>«ENDIF»«ELSE»«outputType»«ENDIF»)'''
		} else {
			''''''
		}
		if (ref.parameters.size == 0) {
			val item = defaultImplicitVariable.name.toDecoratedName(ref.findContainerDefiningImplicitVariable.get)
			'''«item» -> «cast»«bodyExpr»'''
		} else {
			val items = ref.parameters.map[name.toDecoratedName(ref)]
			'''«IF items.size > 1»(«ENDIF»«FOR item : items SEPARATOR ', '»«item»«ENDFOR»«IF items.size > 1»)«ENDIF» -> «cast»«bodyExpr»'''
		}
	}
	
	def StringConcatenationClient onlyElement(RosettaOnlyElement expr, JavaScope scope) {
		return '''«MapperS».of(«expr.argument.javaCode(scope)».get())'''
	}
	
	def StringConcatenationClient filterOperation(FilterOperation op, JavaScope scope) {
		'''
		«op.argument.emptyToMapperJavaCode(scope, true)»
			.«IF op.functionRef.isItemMulti»filterList«ELSE»filterItem«ENDIF»(«op.functionRef.functionReference(scope, true, false)»)'''
	}
	
	def StringConcatenationClient mapOperation(MapOperation op, JavaScope scope) {
		val isBodyMulti =  op.functionRef.isBodyExpressionMulti
		val funcExpr = op.functionRef.functionReference(scope, true, true)
		
		if (!op.isPreviousOperationMulti) {
			if (isBodyMulti) {
				'''
				«op.argument.emptyToMapperJavaCode(scope, false)»
					.mapSingleToList(«funcExpr»)'''
			} else {
				buildSingleItemListOperationOptionalBody(op, "mapSingleToItem", scope)
			}
		} else {
			if (op.argument.isOutputListOfLists) {
				if (isBodyMulti) {
					'''
					«op.argument.emptyToMapperJavaCode(scope, false)»
						.mapListToList(«funcExpr»)'''
				} else {
					'''
					«op.argument.emptyToMapperJavaCode(scope, false)»
						.mapListToItem(«funcExpr»)'''
				}
			} else {
				if (isBodyMulti) {
					'''
					«op.argument.emptyToMapperJavaCode(scope, false)»
						.mapItemToList(«funcExpr»)'''
				} else {
					buildSingleItemListOperationOptionalBody(op, "mapItem", scope)
				}
			}
		}
	}
	
	def StringConcatenationClient extractAllOperation(ExtractAllOperation op, JavaScope scope) {
		val funcExpr = op.functionRef.functionReference(scope, false, true)
		'''
		«op.argument.emptyToMapperJavaCode(scope, false)»
			.apply(«funcExpr»)'''
	}
	
	def StringConcatenationClient flattenOperation(FlattenOperation op, JavaScope scope) {
		buildListOperationNoBody(op, "flattenList", scope)
	}
	
	def StringConcatenationClient distinctOperation(DistinctOperation op, JavaScope scope) {
		distinct(op.argument.javaCode(scope))
	}
	
	def StringConcatenationClient sumOperation(SumOperation op, JavaScope scope) {
		buildListOperationNoBody(op, "sum" + op.inputRawType, scope)
	}
	
	def StringConcatenationClient minOperation(MinOperation op, JavaScope scope) {
		buildSingleItemListOperationOptionalBody(op, "min", scope)
	}
	
	def StringConcatenationClient maxOperation(MaxOperation op, JavaScope scope) {
		buildSingleItemListOperationOptionalBody(op, "max", scope)
	}
	
	def StringConcatenationClient sortOperation(SortOperation op, JavaScope scope) {
		buildSingleItemListOperationOptionalBody(op, "sort", scope)
	}
	
	def StringConcatenationClient reverseOperation(ReverseOperation op, JavaScope scope) {
		buildListOperationNoBody(op, "reverse", scope)
	}
	
	def StringConcatenationClient reduceOperation(ReduceOperation op, JavaScope scope) {
		val outputType =  op.functionRef.bodyRawType
		'''
		«op.argument.javaCode(scope)»
			.<«outputType»>reduce(«op.functionRef.functionReference(scope, true, true)»)'''
	}
	
	def StringConcatenationClient firstOperation(FirstOperation op, JavaScope scope) {
		buildListOperationNoBody(op, "first", scope)
	}
	
	def StringConcatenationClient lastOperation(LastOperation op, JavaScope scope) {
		buildListOperationNoBody(op, "last", scope)
	}
	
	def StringConcatenationClient oneOfOperation(OneOfOperation op, JavaScope scope) {
		val type = typeProvider.getRType(op.argument) as RDataType
		buildConstraint(op.argument, type.data.allAttributes, Necessity.REQUIRED, scope)
	}
	
	def StringConcatenationClient choiceOperation(ChoiceOperation op, JavaScope scope) {
		buildConstraint(op.argument, op.attributes, op.necessity, scope)
	}
	
	private def StringConcatenationClient buildConstraint(RosettaExpression arg, Iterable<Attribute> usedAttributes, Necessity validationType, JavaScope scope) {
		'''«runtimeMethod('choice')»(«arg.javaCode(scope)», «Arrays».asList(«usedAttributes.join(", ")['"' + name + '"']»), «ChoiceRuleValidationMethod».«validationType.name()»)'''
	}
	
	private def StringConcatenationClient buildListOperationNoBody(RosettaUnaryOperation op, String name, JavaScope scope) {
		'''
		«op.argument.emptyToMapperJavaCode(scope, true)»
			.«name»()'''	
	}
	
	private def StringConcatenationClient buildSingleItemListOperationOptionalBody(RosettaFunctionalOperation op, String name, JavaScope scope) {
		if (op.functionRef === null) {
			buildListOperationNoBody(op, name, scope)
		} else {
			buildSingleItemListOperation(op, name, scope)
		}
	}
	
	private def StringConcatenationClient buildSingleItemListOperation(RosettaFunctionalOperation op, String name, JavaScope scope) {
		'''
		«op.argument.emptyToMapperJavaCode(scope, true)»
			.«name»(«op.functionRef.functionReference(scope, true, true)»)'''	
	}
	
	private def StringConcatenationClient buildMapFuncAttribute(Attribute attribute, EObject scopeContext) {
		if(attribute.eContainer instanceof Data) 
			'''"get«attribute.name.toFirstUpper»", «attribute.attributeTypeVariableName(scopeContext)» -> «IF attribute.override»(«attribute.type.toJavaType») «ENDIF»«attribute.attributeTypeVariableName(scopeContext)».get«attribute.name.toFirstUpper»()'''
	}

	private def attributeTypeVariableName(Attribute attribute, EObject scopeContext) {
		(attribute.eContainer as Data).toJavaType.simpleName.toFirstLower.toDecoratedName(scopeContext)
	}
	
	/**
	 * The id for a parameter - either a Class name or a positional index
	 */
//	@org.eclipse.xtend.lib.annotations.Data static class ParamID {
//		RosettaType c
//		int index
//		String name;
//	}
	
	//Class mapping from class name or positional index to the name of a variable defined in the containing code
//	static class ParamMap extends HashMap<ParamID, String> {
//		new(RosettaType c) {
//			if (null !== c)
//				put(new ParamID(c, -1, null), c.name.toFirstLower);
//		}
//		
//		new(RosettaType c, String name) {
//			put(new ParamID(c, -1, null), name);
//		}
//		
//		new(){
//		}
//		
//		def dispatch String getClass(RosettaType c) {
//			return get(new ParamID(c, -1, null))
//		}
//		
//		def dispatch String getClass(Data c) {
//			entrySet.findFirst[e|
//				val type  = e.key.c
//				if (type instanceof Data) {
//					if (type.isSub(c)) return true
//				}
//				false	
//			]?.value
//		}
//		
//		def boolean isSub(Data d1, Data d2) {
//			if (d1==d2) return true
//			return d1.hasSuperType && d1.superType.isSub(d2)
//		}
//	}
	
	/**
	 * Create a string representation of a rosetta function  
	 * mainly used to give human readable names to the mapping functions used to extract attributes
	 */
	def StringConcatenationClient toNodeLabel(RosettaExpression expr) {
		switch (expr) {
			RosettaFeatureCall : {
				toNodeLabel(expr)
			}
			RosettaBinaryOperation : {
				toNodeLabel(expr)
			}
			RosettaStringLiteral : {
				'''\"«expr.value»\"'''
			}
			RosettaConditionalExpression : {
				'''choice'''
			}
			RosettaExistsExpression : {
				'''«toNodeLabel(expr.argument)» exists'''
			}
			RosettaEnumValueReference : {
				'''«expr.enumeration.name»'''
			}
			RosettaEnumValue : {
				'''«expr.name»'''
			}
			ListLiteral : {
				'''[«FOR el:expr.elements SEPARATOR ", " »«el.toNodeLabel»«ENDFOR»]'''
			}
			RosettaLiteral : {
				'''«expr.stringValue»'''
			}
			RosettaCountOperation : {
				'''«toNodeLabel(expr.argument)» count'''
			}
			RosettaSymbolReference : {
				'''«expr.symbol.name»«IF expr.explicitArguments»(«FOR arg:expr.args SEPARATOR ", "»«arg.toNodeLabel»«ENDFOR»)«ENDIF»'''
			}
			RosettaImplicitVariable : {
				'''«defaultImplicitVariable.name»'''
			}
			RosettaOnlyElement : {
				toNodeLabel(expr.argument)
			}
			default :
				'''Unsupported expression type of «expr?.class?.name»'''
		}
	}
	
	def StringConcatenationClient toNodeLabel(RosettaFeatureCall call) {
		val feature = call.feature
		val right = switch feature {
			RosettaMetaType, 
			Attribute, 
			RosettaEnumValue: 
				feature.name
			default: throw new UnsupportedOperationException("Unsupported expression type (feature) " + feature?.getClass)
		}
		
		val receiver = call.receiver
		val left = switch receiver {
			RosettaReference,
			RosettaFeatureCall: {
				toNodeLabel(receiver)
			}
			RosettaOnlyElement : {
				toNodeLabel(receiver.argument)
			}
			default: throw new UnsupportedOperationException("Unsupported expression type (receiver) " + receiver?.getClass)
		}
		
		'''«left»->«right»'''
	}
	
	def StringConcatenationClient toNodeLabel(RosettaBinaryOperation binOp) {
		'''«binOp.left.toNodeLabel» «binOp.operator» «binOp.right.toNodeLabel»'''
	}
}
