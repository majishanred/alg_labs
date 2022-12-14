class Node #Узел дерева
    attr_reader :value, :left_child, :right_child
    attr_writer :value, :left_child, :right_child
    
    def initialize(value, left_child, right_child)
        @value = value
        @left_child = left_child
        @right_child = left_child
    end
end

def construct_tree(string) #Функция построения дерева, не суть важно
    unless string.include?(',') then
        return Node.new(string.to_i, nil, nil)
    end

    num = ''
    node = Node.new(nil, nil, nil)
    braccets = []
    pos = 0
    
    left_child = nil
    right_child = nil
    
    new_str = string

    string.each_char do |char|
        if '123456790'.include?(char) then
            num = num + char
        else
            break
        end
    end

    node.value = num.to_i

    new_str = string[num.size+2...].chop

    new_str.each_char do |char|
        braccets.push(char) if char == '('
        braccets.pop if char == ')'

        pos = pos + 1

        if char == ',' && braccets.empty? then
            break
        end
    end

    left_substr = new_str[...pos-1]
    right_substr = new_str[pos+1...]

    node.left_child = construct_tree(left_substr)
    node.right_child = construct_tree(right_substr)

    node
end

class Tree
    def initialize(tree_string)
        @root = construct_tree(tree_string)
    end

    def insert(node, value) #Вставка эллемента в дерево, все по алгоритму
        if value > node.value
            if node.right_child == nil
                node.right_child = Node.new(value, nil, nil)
                return
            end

            return insert(node.right_child, value)
        elsif value < node.value
            if node.left_child == nil
                node.left_child = Node.new(value, nil, nil)
                return
            end

            return insert(node.left_child, value)
        end
    end

    def find(node, value) #Функция поиска элемента в дереве
        if node.value != value && node.left_child == nil && node.right_child == nil
            puts "Element is not found"
        end

        if node.value == value
            return node
        elsif node.value > value
            return find(node.left_child, value)
        elsif node.value < value
            return find(node.right_child, value)
        end
    end

    def min(node) #Вспомогательная функция для поиска минимального элемента в поддереве
        return min(node.left_child) if node.left_child != nil
        return node
    end

    def delete(nd, value)
        queue = []
        queue.push(nd)
        i = 0

        #Иммитация стека, потому что рекурсия в данном случае не подходит, т.к. перехват идет не в той области видимости и эллементы не удаляются из дерева
        while true
            node = queue[i]
            if node == nil
                return nil
            end
            if value > node.value #Если значение больше значения элемента
                queue.push(node.right_child)
                i = i + 1
            elsif value < node.value #Если значение меньше значения элемента
                queue.push(node.left_child)
                i = i + 1
            elsif value == node.value #Если равно
                if node.left_child == nil && node.right_child == nil #Если оба потомка дерева не существуют
                    queue[i - 1].left_child = nil if value < queue[i - 1].value
                    queue[i - 1].right_child = nil if value > queue[i - 1].value

                    return
                elsif node.left_child != nil && node.right_child != nil #Если оба потомка дерева существуют
                    if node.right_child.left_child == nil #Если левый элемент правого поддерева не существует, то меняем значения
                        if value < queue[i - 1].value 
                            queue[i - 1].left_child = node.left_child 
                            queue[i - 1].left_child.right_child = node.right_child
                        end
                        if value > queue[i - 1].value
                            queue[i - 1].right_child = node.right_child
                            queue[i - 1].right_child.left_child = node.left_child 
                        end
                        return
                    else #В другом случае ищем минимальный элемент правого поддерева, переназначаем, рекурсивно удаляем из правого поддерева найденный элемент
                        min = min(node.right_child)
                        node.value = min.value
                        return delete(node.right_child, min.value)
                    end
                elsif node.right_child != nil || node.left_child != nil #случай, когда один из потомков существует, то мы просто подменяем значения и ссылки
                    queue[i - 1].right_child = node.right_child if node.right_child != nil
                    queue[i - 1].left_child = node.left_child if node.left_child != nil
                    return
                end
            end
        end
    end

    def vivod(node) #Вывод линейно-скобочой записи дерева
        if node == nil then
            return ''
        end

        value = node.value
        
        right_substr = vivod(node.right_child)
        left_substr = vivod(node.left_child)

        return value.to_s + ' (' + left_substr + ', ' + right_substr + ')'
    end

    def root
        @root
    end
end

TREE_STRING = gets.chop #Ввод дерева через консоль

TREE = Tree.new(TREE_STRING) #Инициализация дерева

step = gets #Ввод строки на действия с деревом

while step.chop != '' do
    action = step.downcase.split(' ')[0]
    value = step.downcase.split(' ')[1].to_i

    if action == 'delete'
        TREE.delete(TREE.root, value)
    end

    TREE.insert(TREE.root, value) if action == 'insert'

    step = gets
end

puts TREE.vivod(TREE.root).gsub(/\(\, \)/, '').gsub(/ \,/, ',') #Вывод отформатированной линейно-скобочной записи дерева