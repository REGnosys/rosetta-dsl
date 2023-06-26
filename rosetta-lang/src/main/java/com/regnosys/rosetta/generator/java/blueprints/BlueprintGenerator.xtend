package com.regnosys.rosetta.generator.java.blueprints

import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.RosettaExtensions.PathAttribute
import com.regnosys.rosetta.blueprints.Blueprint
import com.regnosys.rosetta.blueprints.BlueprintBuilder
import com.regnosys.rosetta.blueprints.BlueprintInstance
import com.regnosys.rosetta.blueprints.DataItemReportBuilder
import com.regnosys.rosetta.blueprints.DataItemReportUtils
import com.regnosys.rosetta.blueprints.runner.actions.Filter
import com.regnosys.rosetta.blueprints.runner.actions.FilterByRule
import com.regnosys.rosetta.blueprints.runner.actions.IdChange
import com.regnosys.rosetta.blueprints.runner.actions.rosetta.RosettaActionFactory
import com.regnosys.rosetta.blueprints.runner.data.DataIdentifier
import com.regnosys.rosetta.blueprints.runner.data.GroupableData
import com.regnosys.rosetta.blueprints.runner.data.RuleIdentifier
import com.regnosys.rosetta.blueprints.runner.nodes.SourceNode
import com.regnosys.rosetta.generator.java.JavaIdentifierRepresentationService
import com.regnosys.rosetta.generator.java.JavaScope
import com.regnosys.rosetta.generator.java.expression.ExpressionGenerator
import com.regnosys.rosetta.generator.java.types.JavaClass
import com.regnosys.rosetta.generator.java.types.JavaType
import com.regnosys.rosetta.generator.java.types.JavaTypeVariable
import com.regnosys.rosetta.generator.java.util.ImportManagerExtension
import com.regnosys.rosetta.rosetta.BlueprintExtract
import com.regnosys.rosetta.rosetta.BlueprintFilter
import com.regnosys.rosetta.rosetta.BlueprintLookup
import com.regnosys.rosetta.rosetta.BlueprintNode
import com.regnosys.rosetta.rosetta.BlueprintNodeExp
import com.regnosys.rosetta.rosetta.BlueprintOr
import com.regnosys.rosetta.rosetta.BlueprintRef
import com.regnosys.rosetta.rosetta.BlueprintReturn
import com.regnosys.rosetta.rosetta.RosettaBlueprint
import com.regnosys.rosetta.rosetta.RosettaBlueprintReport
import com.regnosys.rosetta.rosetta.RosettaDocReference
import com.regnosys.rosetta.rosetta.RosettaFactory
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.RosettaRootElement
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.types.RDataType
import com.regnosys.rosetta.types.RType
import com.regnosys.rosetta.utils.DottedPath
import com.regnosys.rosetta.validation.RosettaBlueprintTypeResolver
import com.regnosys.rosetta.validation.TypedBPNode
import com.rosetta.model.lib.path.RosettaPath
import java.util.Collection
import java.util.List
import java.util.Map
import javax.inject.Inject
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend2.lib.StringConcatenationClient
import org.eclipse.xtext.generator.IFileSystemAccess2

import static com.regnosys.rosetta.generator.java.util.ModelGeneratorUtil.*
import com.regnosys.rosetta.generator.java.types.JavaParametrizedType
import com.regnosys.rosetta.generator.java.types.JavaTypeTranslator
import com.regnosys.rosetta.generator.java.RosettaJavaPackages.RootPackage
import com.regnosys.rosetta.types.TypeSystem
import com.regnosys.rosetta.rosetta.TypeCall
import java.util.Optional
import java.util.stream.Stream
import java.util.stream.Collectors
import com.regnosys.rosetta.validation.BindableType
import java.util.function.Supplier
import com.regnosys.rosetta.generator.java.types.JavaReferenceType
import java.math.BigDecimal
import com.regnosys.rosetta.types.CardinalityProvider
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import org.eclipse.xtext.EcoreUtil2
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference
import com.regnosys.rosetta.generator.util.RosettaFunctionExtensions
import com.regnosys.rosetta.types.RosettaTypeProvider
import com.rosetta.model.lib.functions.ModelObjectValidator
import java.util.ArrayList
import com.rosetta.model.lib.mapper.MapperC
import com.rosetta.model.lib.mapper.MapperS

class BlueprintGenerator {
	static Logger LOGGER = LoggerFactory.getLogger(BlueprintGenerator)
	
	@Inject extension ImportManagerExtension
	@Inject extension RosettaBlueprintTypeResolver
	@Inject extension ExpressionGenerator
	@Inject CardinalityProvider cardinality
	@Inject extension RosettaExtensions
	@Inject extension JavaIdentifierRepresentationService
	@Inject extension JavaTypeTranslator
	@Inject extension TypeSystem
	@Inject extension RosettaTypeProvider
	@Inject extension RosettaFunctionExtensions

	/**
	 * generate a blueprint java file
	 */
	def generate(RootPackage root, IFileSystemAccess2 fsa, List<RosettaRootElement> elements, String version) {
		elements.filter(RosettaBlueprintReport).forEach [ report |
			// generate blueprint report
			fsa.generateFile(root.blueprint.withForwardSlashes + '/' + report.name + 'BlueprintReport.java',
				generateBlueprint(root, firstNodeExpression(report), report.name, 'BlueprintReport', report.URI, report.reportType?.name, version))
			// generate output report type builder
			if (report.reportType !== null) {
				fsa.generateFile(root.blueprint.withForwardSlashes + '/' + report.reportType.name.toDataItemReportBuilderName + '.java',
					generateReportBuilder(root, report, version))
			}
		]
		
		elements.filter(RosettaBlueprint)
			.filter[isLegacy]
			.filter[nodes !== null]
			.forEach [ bp |
			fsa.generateFile(root.blueprint.withForwardSlashes + '/' + bp.name + 'Rule.java',
				generateBlueprint(root, bp.nodes, bp.name, 'Rule', bp.URI, null, version))
		]
		elements.filter(RosettaBlueprint)
			.filter[!isLegacy]
			.forEach [ rule |
				val ruleClass = rule.toRuleJavaClass
				fsa.generateFile(ruleClass.canonicalName.withForwardSlashes + ".java",
					nonLegacyGenerateBlueprint(ruleClass, rule, version))
		]
	}

	/**
	 * get first node expression
	 */
	def firstNodeExpression(RosettaBlueprintReport report) {
		var BlueprintNodeExp currentNodeExpr = null
		var BlueprintNodeExp firstNodeExpr = null
		
		for (eligibilityRule : report.eligibilityRules) {
			val ref = RosettaFactory.eINSTANCE.createBlueprintRef
			ref.blueprint = eligibilityRule
			ref.name = eligibilityRule.name
			
			var newNodeExpr = RosettaFactory.eINSTANCE.createBlueprintNodeExp
			newNodeExpr.node = ref
			newNodeExpr.node.name = ref.name
						
			if (null === currentNodeExpr) firstNodeExpr = newNodeExpr
			else currentNodeExpr.next = newNodeExpr
				
			currentNodeExpr = newNodeExpr
		}
		
		val node = RosettaFactory.eINSTANCE.createBlueprintOr
		node.name = report.name
		
		report.getAllReportingRules(false).values.sortBy[name].forEach[
			val ref = RosettaFactory.eINSTANCE.createBlueprintRef
			ref.blueprint = it
			ref.name = it.name
			val rule = RosettaFactory.eINSTANCE.createBlueprintNodeExp
			rule.node = ref
			rule.node.name = ref.name
			node.bps.add(rule)
		]
		
		if (!node.bps.empty) {
			val orNodeExpr = RosettaFactory.eINSTANCE.createBlueprintNodeExp
			orNodeExpr.node = node
			currentNodeExpr.next = orNodeExpr			
		}
			
		return firstNodeExpr
	}

	/**
	 * Generate the text of a blueprint
	 */
	def generateBlueprint(RootPackage packageName, BlueprintNodeExp nodes, String name, String type, String uri, String dataItemReportBuilderName, String version) {
		try {
			
			val typed = buildTypeGraph(nodes)
			val clazz = new JavaClass(packageName.blueprint, name + type)
			val typedJava = typed.toJavaNode(clazz)
			val clazzWithArgs = typedJava.toParametrizedType(clazz)

			val topScope = new JavaScope(packageName.blueprint)

			val classScope = topScope.classScope(clazzWithArgs.toString)

			val StringConcatenationClient body = '''
				«emptyJavadocWithVersion(version)»
				public class «clazzWithArgs» implements «Blueprint»<«typedJava.input», «typedJava.output», «typedJava.inputKey», «typedJava.outputKey»> {
					
					private final «RosettaActionFactory» actionFactory;
					
					@«Inject»
					public «clazz»(«RosettaActionFactory» actionFactory) {
						this.actionFactory = actionFactory;
					}
					
					@Override
					public String getName() {
						return "«name»"; 
					}
					
					@Override
					public String getURI() {
						return "«uri»";
					}
					
					«nodes.buildBody(classScope, typedJava, dataItemReportBuilderName)»
				}
				'''

				buildClass(packageName.blueprint, body, topScope)
			}
			catch (Exception e) {
				LOGGER.error("Error generating blueprint java for "+name, e);
				return '''Unexpected Error generating «name».java Please see log for details'''
			}
	}
	
	def nonLegacyGenerateBlueprint(JavaClass ruleClass, RosettaBlueprint rule, String version) {
		try {
			
			val typed = nonLegacyBuildTypeGraph(rule.expression)
			val typedJava = typed.toJavaNode(ruleClass)
			val clazzWithArgs = typedJava.toParametrizedType(ruleClass)

			val topScope = new JavaScope(ruleClass.packageName)

			val classScope = topScope.classScope(clazzWithArgs.toString)

			val StringConcatenationClient body = '''
				«emptyJavadocWithVersion(version)»
				public class «clazzWithArgs» implements «Blueprint»<«typedJava.input», «typedJava.output», «typedJava.inputKey», «typedJava.outputKey»> {
					
					private final «RosettaActionFactory» actionFactory;
					
					@«Inject»
					public «ruleClass»(«RosettaActionFactory» actionFactory) {
						this.actionFactory = actionFactory;
					}
					
					@Override
					public String getName() {
						return "«rule.name»"; 
					}
					
					@Override
					public String getURI() {
						return "«rule.URI»";
					}
					
					«rule.nonLegacyBuildBody(classScope, typedJava)»
				}
				'''

				buildClass(ruleClass.packageName, body, topScope)
			}
			catch (Exception e) {
				LOGGER.error("Error generating blueprint java for " + ruleClass.canonicalName, e);
				return '''Unexpected Error generating «ruleClass.canonicalName».java Please see log for details'''
			}
	}
	
	/**
	 * Provide Generic names for the blueprint for parameters that haven't been bound to specific classes
	 * and generate the generic args string e.g. <Input, ?, ?, ?> becomes <Input, OUTPUT, INKEY, OUTKEY>
	 */
	def JavaType toParametrizedType(TypedBPJavaNode node, JavaClass clazz) {
		var typeArgs = Stream.of(node.input, node.output, node.inputKey, node.outputKey)
			.filter[it instanceof JavaTypeVariable]
			.map[it as JavaTypeVariable]
			.distinct
			.collect(Collectors.toList)
		if (typeArgs.size>0) {
			return new JavaParametrizedType(clazz, typeArgs)
		} else {
			return clazz
		}
	}
	
	Map<BindableType, JavaType> bindableToJavaTypeCache = newHashMap
	private def JavaType bindableTypeToJavaType(BindableType t, Supplier<? extends JavaReferenceType> defaultType) {
		bindableToJavaTypeCache.computeIfAbsent(t, 
			[
				type.map[
					val javaType = toJavaReferenceType
					if (javaType == JavaClass.from(BigDecimal)) {
						JavaClass.from(Number)
					} else {
						javaType
					}
				].orElseGet(defaultType)
			]
		)
	}
	def TypedBPJavaNode toJavaNode(TypedBPNode node, JavaClass clazz) {
		val result = new TypedBPJavaNode
		result.original = node
		result.input = bindableTypeToJavaType(node.input, [new JavaTypeVariable(clazz, "IN")])
		result.output = bindableTypeToJavaType(node.output, [new JavaTypeVariable(clazz, "OUT")])
		result.inputKey = bindableTypeToJavaType(node.inputKey, [new JavaTypeVariable(clazz, "INKEY")])
		result.outputKey = bindableTypeToJavaType(node.outputKey, [new JavaTypeVariable(clazz, "OUTKEY")])
		result.next = node.next?.toJavaNode
		result.orNodes = node.orNodes.map[toJavaNode]
		return result
	}
	def TypedBPJavaNode toJavaNode(TypedBPNode node) {
		val result = new TypedBPJavaNode
		result.original = node
		result.input = bindableTypeToJavaType(node.input, [JavaClass.from(Object)])
		result.output = bindableTypeToJavaType(node.output, [JavaClass.from(Object)])
		result.inputKey = bindableTypeToJavaType(node.inputKey, [JavaClass.from(Object)])
		result.outputKey = bindableTypeToJavaType(node.outputKey, [JavaClass.from(Object)])
		result.next = node.next?.toJavaNode
		result.orNodes = node.orNodes.map[toJavaNode]
		return result
	}
	
	/**
	 * build the body of the blueprint class
	 */
	def StringConcatenationClient buildBody(BlueprintNodeExp nodes, JavaScope scope, TypedBPJavaNode typedNode, String dataItemReportBuilderName) {
		nodes.functionDependencies.toSet.forEach[
			scope.createIdentifier(it.toFunctionInstance, it.name.toFirstLower)
		]
		nodes.ruleDependencies.toSet.forEach[
			scope.createIdentifier(it.toRuleInstance, it.name.toFirstLower + "Ref")
		]

		val context = new Context(nodes)
		val blueprintScope = scope.methodScope("blueprint")
		return '''
			«FOR dep : nodes.functionDependencies.toSet»
				@«Inject» protected «dep.toFunctionJavaClass» «scope.getIdentifierOrThrow(dep.toFunctionInstance)»;
			«ENDFOR»
			«FOR dep : nodes.ruleDependencies.toSet»
				@«Inject» protected «dep.toRuleJavaClass» «scope.getIdentifierOrThrow(dep.toRuleInstance)»;
			«ENDFOR»
			
			@Override
			public «BlueprintInstance»<«typedNode.input», «typedNode.output», «typedNode.inputKey», «typedNode.outputKey»> blueprint() {
				return 
					«importWildcard(method(BlueprintBuilder, "startsWith"))»(actionFactory, «nodes.buildGraph(blueprintScope, typedNode.next, context)»)
					«IF dataItemReportBuilderName !== null».addDataItemReportBuilder(new «dataItemReportBuilderName.toDataItemReportBuilderName»())«ENDIF»
					.toBlueprint(getURI(), getName());
			}
			«FOR bpRef : context.bpRefs.entrySet»
			
			«bpRef.key.blueprintRef(scope, bpRef.value)»
			«ENDFOR»
		'''
	}
	def StringConcatenationClient nonLegacyBuildBody(RosettaBlueprint rule, JavaScope classScope, TypedBPJavaNode typedNode) {
		val expr = rule.expression
		val outputType = expr.RType
		val outputIsMany = cardinality.isMulti(expr)
		val outputJavaType = if (outputType.needsBuilder) {
			outputType.toPolymorphicListOrSingleJavaType(outputIsMany)
		} else {
			outputType.toListOrSingleJavaType(outputIsMany)
		}
		val outputJavaBuilderType = outputType.toBuilderType(outputIsMany)
		val outNeedsBuilder = needsBuilder(outputType)
		val objectValidatorId = classScope.createUniqueIdentifier("objectValidator")
		expr.functionDependencies.toSet.forEach[
			classScope.createIdentifier(it.toFunctionInstance, it.name.toFirstLower)
		]
		expr.ruleDependencies.toSet.forEach[
			classScope.createIdentifier(it.toRuleInstance, it.name.toFirstLower + "Ref")
		]
		
		val evaluateScope = classScope.methodScope("evaluate")
		evaluateScope.createIdentifier(rule.toRuleInputParameter, rule.input.type.name.toFirstLower)
		evaluateScope.createIdentifier(rule.toRuleOutputParameter, outputType.name.toFirstLower)

		val doEvaluateScope = classScope.methodScope("doEvaluate")
		doEvaluateScope.createIdentifier(rule.toRuleInputParameter, rule.input.type.name.toFirstLower)
		doEvaluateScope.createIdentifier(rule.toRuleOutputParameter, outputType.name.toFirstLower)
		
		val assignOutputScope = classScope.methodScope("assignOutput")
		assignOutputScope.createIdentifier(rule.toRuleInputParameter, rule.input.type.name.toFirstLower)
		assignOutputScope.createIdentifier(rule.toRuleOutputParameter, outputType.name.toFirstLower)

		val blueprintScope = classScope.methodScope("blueprint")
		
		return '''
			«IF outNeedsBuilder»
				
				@«Inject» protected «ModelObjectValidator» «objectValidatorId»;
			«ENDIF»
			«FOR dep : expr.functionDependencies.toSet»
				@«Inject» protected «dep.toFunctionJavaClass» «classScope.getIdentifierOrThrow(dep.toFunctionInstance)»;
			«ENDFOR»
			«FOR dep : expr.ruleDependencies.toSet»
				@«Inject» protected «dep.toRuleJavaClass» «classScope.getIdentifierOrThrow(dep.toRuleInstance)»;
			«ENDFOR»
			
			@Override
			public «BlueprintInstance»<«typedNode.input», «typedNode.output», «typedNode.inputKey», «typedNode.outputKey»> blueprint() {
				return
					«importWildcard(method(BlueprintBuilder, "startsWith"))»(actionFactory, «rule.nonLegacyBuildNode(blueprintScope, typedNode.next, outputType, outputIsMany)»)
						.toBlueprint(getURI(), getName());
			}
			
			public «outputJavaType» evaluate(«rule.inputAsParameter(evaluateScope)») {
				«outputJavaBuilderType» «evaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)» = doEvaluate(«rule.inputAsArgument(evaluateScope)»);
				«IF outNeedsBuilder»
				if («evaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)» != null) {
					«objectValidatorId».validate(«outputType.toJavaType».class, «evaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)»);
				}
				«ENDIF»
				return «evaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)»;
			}
			
			private «outputJavaBuilderType» doEvaluate(«rule.inputAsParameter(doEvaluateScope)») {
				«outputJavaBuilderType» «doEvaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)» = «IF outputIsMany»new «ArrayList»<>()«ELSEIF outNeedsBuilder»«outputType.toListOrSingleJavaType(outputIsMany)».builder()«ELSE»null«ENDIF»;
				return assignOutput(«doEvaluateScope.getIdentifierOrThrow(rule.toRuleOutputParameter)»,«rule.inputAsArgument(doEvaluateScope)»);
			}
			
			private «outputJavaBuilderType» assignOutput(«outputJavaBuilderType» «assignOutputScope.getIdentifierOrThrow(rule.toRuleOutputParameter)», «rule.inputAsParameter(assignOutputScope)») {
				«assign(assignOutputScope, rule, outputType, outputIsMany)»

				return «IF !needsBuilder(outputType)»«assignOutputScope.getIdentifierOrThrow(rule.toRuleOutputParameter)»«ELSE»«Optional».ofNullable(«assignOutputScope.getIdentifierOrThrow(rule.toRuleOutputParameter)»)
					.map(«IF outputIsMany»o -> o.stream().map(i -> i.prune()).collect(«Collectors».toList())«ELSE»o -> o.prune()«ENDIF»)
					.orElse(null)«ENDIF»;
			}
		'''
	}
	private def StringConcatenationClient inputAsArgument(RosettaBlueprint rule, JavaScope scope) {
		'''«scope.getIdentifierOrThrow(rule.toRuleInputParameter)»'''
	}
	private def StringConcatenationClient inputAsParameter(RosettaBlueprint rule, JavaScope scope) {
		'''«inputParameterType(rule)» «scope.getIdentifierOrThrow(rule.toRuleInputParameter)»'''
	}
	private def StringConcatenationClient inputParameterType(RosettaBlueprint rule) {
		'''«IF rule.input.needsBuilder»«rule.input.typeCallToRType.toPolymorphicListOrSingleJavaType(false)»«ELSE»«rule.input.typeCallToRType.toListOrSingleJavaType(false)»«ENDIF»'''
	}
	private def JavaType toBuilderType(RType type, boolean isMany) {
		var javaType = type.toJavaReferenceType as JavaClass
		if (needsBuilder(type)) javaType = javaType.toBuilderType
		if (isMany) {
			return new JavaParametrizedType(JavaClass.from(List), javaType)
		} else {
			return javaType
		}
	}
	private def StringConcatenationClient assign(JavaScope scope, RosettaBlueprint rule, RType outputType, boolean outputIsMany) {		
		'''
		«IF needsBuilder(outputType)»
			«scope.getIdentifierOrThrow(rule.toRuleOutputParameter)» = toBuilder(«assignPlainValue(scope, rule.expression, outputIsMany)»);
		«ELSE»
			«scope.getIdentifierOrThrow(rule.toRuleOutputParameter)» = «assignPlainValue(scope, rule.expression, outputIsMany)»;«ENDIF»'''	
	}
	private def StringConcatenationClient assignPlainValue(JavaScope scope, RosettaExpression expr, boolean outputIsMany) {
		'''«javaCode(expr, scope)»«IF outputIsMany».getMulti()«ELSE».get()«ENDIF»'''
	}
	
	/**
	 * recursive function that builds the graph of nodes
	 */
	def StringConcatenationClient buildGraph(BlueprintNodeExp nodeExp, JavaScope scope, TypedBPJavaNode typedNode, Context context)
		'''
		«nodeExp.buildNode(scope, typedNode, context)»«IF nodeExp.next !== null»)
		.then(« nodeExp.next.buildGraph(scope, typedNode.next, context)»«ENDIF»'''
	
	/**
	 * write out an individual graph node
	 */
	def StringConcatenationClient buildNode(BlueprintNodeExp nodeExp, JavaScope scope, TypedBPJavaNode typedNode, Context context) {
		val node = nodeExp.node
		val id = createIdentifier(nodeExp);
		switch (node) {
			BlueprintExtract: {
				val cond = node.call
				val multi = cardinality.isMulti(cond)
				val repeatable = node.repeatable
				
				val lambdaScope = scope.lambdaScope
				val implicitVar = typedNode.original.input.type.map[if (it instanceof RDataType) {
					lambdaScope.createIdentifier(it.toBlueprintImplicitVar, it.name.toFirstLower)
				} else {
					lambdaScope.createUniqueIdentifier(it.name.toFirstLower)
				}].orElseGet[lambdaScope.createUniqueIdentifier("object")]

				if (!multi)
				'''actionFactory.<«typedNode.input», «
					typedNode.output», «typedNode.inputKey»>newRosettaSingleMapper("«node.URI»", "«(cond).toNodeLabel
						»", «id», «implicitVar» -> «node.call.javaCode(lambdaScope)»)'''
				else if (repeatable)
				'''actionFactory.<«typedNode.input», «
									typedNode.output», «typedNode.inputKey»>newRosettaRepeatableMapper("«node.URI»", "«(cond).toNodeLabel
														»", «id», «implicitVar» -> «node.call.javaCode(lambdaScope)»)'''
				else
				'''actionFactory.<«typedNode.input», «
									typedNode.output», «typedNode.inputKey»>newRosettaMultipleMapper("«node.URI»", "«(cond).toNodeLabel
														»", «id», «implicitVar» -> «node.call.javaCode(lambdaScope)»)'''
			}
			BlueprintReturn: {
				val expr = node.expression

				val lambdaScope = scope.lambdaScope

				'''actionFactory.<«typedNode.input», «typedNode.output», «typedNode.inputKey»> newRosettaReturn("«node.URI»", "«expr.toNodeLabel»",  «id»,  () -> «expr.javaCode(lambdaScope)»)'''
			}
			BlueprintLookup: {
				val nodeName = if (nodeExp.identifier !== null) nodeExp.identifier else node.name
				//val lookupLamda = '''«typedNode.input.type.name.toFirstLower» -> lookup«node.name»(«typedNode.input.type.name.toFirstLower»)'''
				'''actionFactory.<«typedNode.input», «
					typedNode.output», «typedNode.inputKey»>newRosettaLookup("«node.URI»", "«nodeName»", «id», "«node.name»")'''
			
			}
			BlueprintOr : {
				node.orNode(scope, typedNode, context, id)
			}
			BlueprintRef : {
				context.addBPRef(typedNode)
				'''get«node.blueprint.name.toFirstUpper»()«IF nodeExp.identifier!==null»)
				.then(new «IdChange»("«node.URI»", "as «nodeExp.identifier»", «id»)«ENDIF»'''
			}
			BlueprintFilter :{
				if(node.filter!==null) {
					val lambdaScope = scope.lambdaScope
					val implicitVar = typedNode.original.input.type.map[if (it instanceof RDataType) {
						lambdaScope.createIdentifier(it.toBlueprintImplicitVar, it.name.toFirstLower)
					} else {
						lambdaScope.createUniqueIdentifier(it.name.toFirstLower)
					}].orElseGet[lambdaScope.createUniqueIdentifier("object")]
					'''new «Filter»<«typedNode.input», «typedNode.inputKey»>("«node.URI»", "«node.filter.toNodeLabel»", «implicitVar
						» -> «node.filter.javaCode(lambdaScope)».get(), «id»)'''
				}
				else {
					context.addBPRef(typedNode)
					'''new «FilterByRule»<«typedNode.input», «typedNode.inputKey»>("«node.URI»", "«node.filterBP.blueprint.name»",
					get«node.filterBP.blueprint.name.toFirstUpper»(), «id»)'''
				}
			}
			default: {
				throw new UnsupportedOperationException("Can't generate code for node of type "+node.class)
			}
		}
	}
	def StringConcatenationClient nonLegacyBuildNode(RosettaBlueprint rule, JavaScope scope, TypedBPJavaNode typedNode, RType outputType, boolean outputIsMany) {
		val id = nonLegacyCreateIdentifier(rule)
				
		val lambdaScope = scope.lambdaScope
		val lambdaParam = lambdaScope.createUniqueIdentifier(rule.input.type.name.toFirstLower)

		if (!outputIsMany)
		'''actionFactory.<«typedNode.input», «
			typedNode.output», «typedNode.inputKey»>newRosettaSingleMapper("«rule.URI»", "«rule.expression.toNodeLabel
				»", «id», «lambdaParam» -> «IF outputIsMany»«MapperC»«ELSE»«MapperS»«ENDIF».of(evaluate(«lambdaParam»)))'''
		else
		'''actionFactory.<«typedNode.input», «
			typedNode.output», «typedNode.inputKey»>newRosettaMultipleMapper("«rule.URI»", "«rule.expression.toNodeLabel
								»", «id», «lambdaParam» -> «IF outputIsMany»«MapperC»«ELSE»«MapperS»«ENDIF».of(evaluate(«lambdaParam»)))'''
	}
	
	def StringConcatenationClient createIdentifier(BlueprintNodeExp nodeExp) {
		if (nodeExp.identifier !== null) {
			return '''new «RuleIdentifier»("«nodeExp.identifier»", getClass())'''
		}
		val node = nodeExp.node
		switch (node) {
			BlueprintExtract: {
				val nodeName = if (node.name !== null) node.name
								else node.call.toNodeLabel
				'''new «RuleIdentifier»("«nodeName»", getClass())'''
			}
			BlueprintReturn: {
				val nodeName = if (node.name !== null) node.name
								else node.expression.toNodeLabel
				
				'''new «RuleIdentifier»("«nodeName»", getClass())'''
			}
			BlueprintLookup: {
				'''new «RuleIdentifier»("Lookup «node.name»", getClass())'''
			}
			default: {
				'''null'''
			}
		}
	}
	def StringConcatenationClient nonLegacyCreateIdentifier(RosettaBlueprint rule) {
		if (rule.identifier !== null) {
			return '''new «RuleIdentifier»("«rule.identifier»", getClass())'''
		}
		return '''null'''
		// val nodeName = rule.expression.toNodeLabel
		// return '''new «RuleIdentifier»("«nodeName»", getClass())'''
	}
	
	static def getURI(EObject eObject) {
		val res = eObject.eResource;
		if (res !== null) {
			val uri = res.URI
			return uri.lastSegment +"#" + res.getURIFragment(eObject)
		} else {
			val id = EcoreUtil.getID(eObject);
			if (id !== null) {
				return id;
			} else {
				return "";
			}
		}
	}
	
	def StringConcatenationClient orNode(BlueprintOr orNode, JavaScope scope, TypedBPJavaNode orTyped, Context context, StringConcatenationClient id) {
		'''
		«IF !orNode.bps.isEmpty»
			«BlueprintBuilder».<«orTyped.getOutFullS»>or(actionFactory,
				«FOR bp:orNode.bps.indexed  SEPARATOR ","»
				«importWildcard(method(BlueprintBuilder, "startsWith"))»(actionFactory, «bp.value.buildGraph(scope, orTyped.orNodes.get(bp.key), context)»)
				«ENDFOR»
				)
			«ENDIF»
		'''
	}
	
	def StringConcatenationClient getOutFullS(TypedBPJavaNode node) {
		'''«node.input», «node.output», «node.inputKey», «node.outputKey»'''
	}
	
	def StringConcatenationClient blueprintRef(RosettaBlueprint ref, JavaScope scope, TypedBPJavaNode typedNode) {
		'''
		protected «BlueprintInstance»«typedNode.typeArgs» get«ref.name.toFirstUpper»() {
			return «scope.getIdentifierOrThrow(ref.toRuleInstance)».blueprint();
		}'''
	}

		
	protected def StringConcatenationClient typeArgs(TypedBPJavaNode typedNode)
		'''<«typedNode.input», «typedNode.output», «typedNode.inputKey», «typedNode.outputKey»>'''
		
	
	def StringConcatenationClient getSource(String source, TypedBPJavaNode node, Context context)
	'''
		protected «SourceNode»<«node.output», «node.outputKey»> get«source.toFirstUpper()»() {
			throw new «UnsupportedOperationException»();
		}
	'''
	
	def fullname(TypeCall type, RootPackage packageName) {
		if (type instanceof com.regnosys.rosetta.rosetta.simple.Data)
			'''«packageName».«type.name»'''.toString
		else 
			type.typeCallToRType.toJavaType
	}
	
	def Iterable<Function> functionDependencies(EObject obj) {
		(if (obj instanceof RosettaSymbolReference) {
			EcoreUtil2.eAllOfType(obj, RosettaSymbolReference) + #[obj]
		} else {
			EcoreUtil2.eAllOfType(obj, RosettaSymbolReference)
		})
			.map[symbol]
			.filter(Function)
	}
	
	def Iterable<RosettaBlueprint> ruleDependencies(EObject obj) {
		(if (obj instanceof RosettaSymbolReference) {
			EcoreUtil2.eAllOfType(obj, RosettaSymbolReference) + #[obj]
		} else {
			EcoreUtil2.eAllOfType(obj, RosettaSymbolReference)
		})
			.map[symbol]
			.filter(RosettaBlueprint)
		+ (if (obj instanceof BlueprintRef) {
			EcoreUtil2.eAllOfType(obj, BlueprintRef) + #[obj]
		} else {
			EcoreUtil2.eAllOfType(obj, BlueprintRef)
		})
			.map[blueprint]
	}

	/**
	 * Builds DataItemReportBuilder that takes a list of GroupableData
	 */
	def String generateReportBuilder(RootPackage packageName, RosettaBlueprintReport report, String version) {
		try {
			val scope = new JavaScope(packageName.blueprint)

			val StringConcatenationClient body = '''
				«emptyJavadocWithVersion(version)»
				public class «report.reportType.name.toDataItemReportBuilderName» implements «DataItemReportBuilder» {
				
					«report.buildDataItemReportBuilderBody»
				}
				'''
			buildClass(packageName.blueprint, body, scope)
		}
		catch (Exception e) {
			LOGGER.error("Error generating blueprint java for "+report.reportType.name, e);
			return '''Unexpected Error generating «report.reportType.name».java Please see log for details'''
		}
	}
	
	def StringConcatenationClient buildDataItemReportBuilderBody(RosettaBlueprintReport report) {
		val reportType = new RDataType(report.reportType).toJavaType
		val builderName = "dataItemReportBuilder"
		'''
		@Override
		public <T> «reportType» buildReport(«Collection»<«GroupableData»<?, T>> reportData) {
			«reportType».«reportType»Builder «builderName» = «reportType».builder();
			
			for («GroupableData»<?, T> groupableData : reportData) {
				«DataIdentifier» dataIdentifier = groupableData.getIdentifier();
				if (dataIdentifier instanceof «RuleIdentifier») {
					«RuleIdentifier» ruleIdentifier = («RuleIdentifier») dataIdentifier;
					«Class»<?> ruleType = ruleIdentifier.getRuleType();
					«Object» data = groupableData.getData();
					if (data == null) {
						continue;
					}
					«report.getAllReportingRules(true).buildRules(builderName)»
				}
			}
			
			return «builderName».build();
		}'''
	}
	
	def StringConcatenationClient buildRules(Map<PathAttribute, RosettaBlueprint> attrRules, String builderPath) {
		'''«FOR entry : attrRules.entrySet.sortBy[value.name]»
			«val path = entry.key.path»
			«val attr = entry.key.attr»
			«val attrType = attr.typeCall.typeCallToRType»
			«val rule = entry.value»
			«val ruleClass = new JavaClass(DottedPath.splitOnDots((rule.eContainer as RosettaModel).name).child("blueprint"), rule.name + "Rule")»
			if («ruleClass».class.isAssignableFrom(ruleType)) {
				«DataItemReportUtils».setField(«builderPath»«path.trimFirst.buildAttributePathGetters»::set«attr.name.toFirstUpper», «attrType.toJavaReferenceType».class, data, «ruleClass».class);
			}
		«ENDFOR»
		'''	
	}
	
	private def buildAttributePathGetters(RosettaPath path) {
		if (path === null) {
			return ""
		}

		return "." + path.allElements.map[
				'''«IF it.index.isPresent»getOrCreate«it.path.toFirstUpper»(ruleIdentifier.getRepeatableIndex().orElse(0))«ELSE»getOrCreate«it.path.toFirstUpper»()«ENDIF»'''
			].join('.')
	}

	def String toDataItemReportBuilderName(String dataItemReportTypeName) {
		'''«dataItemReportTypeName»_DataItemReportBuilder'''
	}
	
	@Data static class AttributePath {
		List<Attribute> path
		RosettaDocReference ref
	}
	
	@Data static class RegdOutputField {
		Attribute attrib
		RosettaDocReference ref
	}
	
	@Data static class Context {
		BlueprintNodeExp nodes
		Map<RosettaBlueprint, TypedBPJavaNode> bpRefs = newLinkedHashMap
		
		def addBPRef(TypedBPJavaNode node) {
			addBPRef(node.original.node, node)		
		}
		def dispatch addBPRef(BlueprintNode node, TypedBPJavaNode nodeType) {
			LOGGER.error("unexpected node type adding bpRef")
			""
		}
		def dispatch addBPRef(BlueprintRef ref, TypedBPJavaNode node) {
			bpRefs.put(ref.blueprint, node)
		}
		
		def dispatch addBPRef(BlueprintFilter ref, TypedBPJavaNode node) {
			bpRefs.put(ref.filterBP.blueprint, node.orNodes.get(0))
		}
		
	}
}
