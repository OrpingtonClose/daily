def bits_in_product(A, B):
    bits = [False for _ in range(0, 56)]
    product = A * B
    for index, bit in enumerate(bits):
        if product & 2**index != 0:
            bits[index] = True
    return sum(bits)

def digit_zip(A, B):
    # zips the digits of two integers
    def get_digits(integer):
        import math
        result = []
        if integer != 0:
            for digit in range(0, math.trunc(math.log10(integer)) + 1):
                result += [(integer // 10 ** digit) % 10]
        return result
    both_digits = [get_digits(A)]
    both_digits += [get_digits(B)]
    disassembled_result = []
    while all([len(digits) != 0 for digits in both_digits]):
        disassembled_result += [both_digits[0].pop(), both_digits[1].pop()]
    disassembled_result += both_digits[0][::-1]
    disassembled_result += both_digits[1][::-1]
    
    result_number = 0
    while len(disassembled_result) != 0:
        current_length = len(disassembled_result) - 1
        result_number += disassembled_result.pop(0) * (10 ** current_length)
        
    return result_number     

def intersection_area_of_two_circles(x1, y1, r1, x2, y2, r2):
    import math
    if r1 == 0 or r2 == 0:
        return 0.0
    x_distance = abs(x1 - x2)
    y_distance = abs(y1 - y2)
    c = math.sqrt(x_distance ** 2 + y_distance ** 2)
    distance_for_contact = r1 + r2
    if c >= distance_for_contact:
        return 0.0
"""
    x_intersection_point = (r1**2 - r2**2 + c**2) / (2*c)
    y_intersection_point = math.sqrt(r1**2 - x_intersection_point)
    a = r1**2
    b = r2**2
    x = (a - b + c**2) / (2 * d)
    z = x**2
    y = math.sqrt(a-z)
    return r1**2 * math.asin( y_intersection_point / r1 ) + r2**2 * math.asin( y_intersection_pointy / r2 ) - y_intersection_point * (x_intersection_point + math.sqrt(z + b - a))
"""
