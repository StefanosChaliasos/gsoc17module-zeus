#include "libff_wrapper.h"

size_t get_g2_exp_window_size(size_t g2_exp_count) {
    return get_exp_window_size<G2<curve>>(g2_exp_count);
}

window_table<G2<curve>> get_g2_window_table(size_t window_size, G2<curve> elem) {
    return get_window_table(Fr<curve>::size_in_bits(), window_size, elem);
}

G2<curve> g2_mul(size_t window_size, window_table<G2<curve>> *g2_table, Fr<curve> other) {
    return windowed_exp(Fr<curve>::size_in_bits(), window_size, *g2_table, other);
}

size_t get_g1_exp_window_size(size_t g1_exp_count) {
    return get_exp_window_size<G1<curve>>(g1_exp_count);
}

window_table<G1<curve>> get_g1_window_table(size_t window_size, G1<curve> elem) {
    return get_window_table(Fr<curve>::size_in_bits(), window_size, elem);
}

G1<curve> g1_mul(size_t window_size, window_table<G1<curve>> *g1_table, Fr<curve> other) {
    return windowed_exp(Fr<curve>::size_in_bits(), window_size, *g1_table, other);
}

GT<curve> pair(G1<curve> g1, G2<curve> g2) {
    return curve::reduced_pairing(g1, g2);
}

Fr<curve> get_order() {
    return Fr<curve>::one();
}
